require 'optparse'
require 'yaml'

module Buildmeister
  class Launcher
    def self.launch(*args)
      @options = {:mode => :verbose}
            
      OptionParser.new do |opts|
        opts.banner = "Usage: buildmeister notify"
        
        opts.on('-q', '--quiet', 'Quiet') do
          @options[:mode] = :quiet
        end
        
        opts.on('-f', '--from-bin BIN_NAME', 'Move From Bin') do |f|
          @options[:move_from] = f
        end
        
        opts.on('-t', '--to-state STATE', 'Move to State') do |t|
          @options[:to_state] = t
        end
        
        opts.on('-p', '--project PROJECT', 'Use Project') do |p|
          @options[:project] = p
        end
        
        opts.on('-b', '--bin-name BIN', 'Summary Bin Name') do |p|
          @options[:bin_name] = p
        end

        opts.on('-c', '--compare-branch BRANCH', 'Compare From Branch') do |c|
          @options[:compare_branch] = c || 'master'
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit_app
        end
        
        if args.empty?
          puts opts
          exit_app
        end
      end.parse!(args)
      
      @options[:command] = args.shift      

      Base.new(@options)
    end
    
    def self.exit_app
      exit
    end
  end

  class Base
    include StringUtils
    include GitUtils
    
    RETRY_COUNT = 5
    
    attr_accessor :projects, :notification_interval, :command, :args
    
    def initialize(options = {})
      @options = options
            
      # Lighthouse setup
      @config  = Buildmeister::Base.load_config
      @account = Lighthouse::Account.new(@config['account'], @config['token'])
      
      self.projects = []
      
      projects.extend Finder
      
      if @options[:project]
        @config['projects'] = @config['projects'].select { |p| p['name'] == @options[:project] } 
        raise "#{@options[:project]} did not match any projects in the config file" if (@config['projects'] || []).empty?
      end
      
      @config['projects'].each do |project_name|
        self.projects << Buildmeister::Project.new(project_name, @account, @options)
      end
      
      self.notification_interval = @config['notification_interval']
      
      # Did we pass in a command?
      self.command = options[:command]
    end
    
    def go!
      send command if command
    end
    
    def changed?
      projects.any?(&:changed?)
    end
    
    def title
      "Buildmeister: #{Time.now.strftime("%m/%d %I:%M %p")}"
    end
    
    def notify
      puts "Starting Buildmeister Notify..."

      retry_count = RETRY_COUNT

      loop do
        begin
          body = ''

          body << projects.map do |project|
            "#{project.display}\n"
          end.join("\n")

          puts "Updated notification at #{Time.now.strftime("%m/%d %I:%M %p")}"

          if changed? || @force
            Buildmeister::Notifier.post(title, body)
            @force = false
          end

          sleep notification_interval * 60

          refresh!

          # Reset the retry count, since we successfully completed this iteration
          retry_count = RETRY_COUNT

        rescue StandardError => e        
          if retry_count < 1
            puts "Retried #{RETRY_COUNT} times... I give up!"
            raise e
          else
            # Exponential falloff...
            sleep_time = (50.0 * (1 / (retry_count / 2.0))).to_i

            puts "Caught error: #{e.class.name}: #{e.message}"
            puts "#{retry_count} more tries... sleeping #{sleep_time} seconds..."

            sleep sleep_time

            retry_count -= 1

            retry
          end
        rescue Interrupt => i
          puts "\rPress ^C again to quit..."
          sleep 3
          @force = true
          refresh!
          retry
        end
      end
    end
    
    def move_all
      bin_name = @options[:move_from]
      
      if projects.size > 1
        puts "#{projects.size} projects are loaded (#{projects.map(&:name).join(', ')})"
        puts "Do you really want to move tickets in all projects? [y/n]"
        
        choice = gets
        
        if choice.downcase.strip == 'n'
          puts "aborting..."
          return
        end
      end
      
      projects.each do |project|
        project.bins.named(bin_name).tickets.each do |ticket|
          puts "processing #{project.name}: #{ticket.id}"
          ticket.state = @options[:to_state]
          ticket.save
        end
      end

      puts "All tickets from bin #{@options[:move_from]} have been moved to #{@options[:to_state]}"
    end

    def list_staged_tickets
      # First, fetch origin to make sure we have all the necessary information
      system('git fetch origin')
      shas = `git log origin/#{@options[:compare_branch]}..HEAD --pretty=format:%H`.split

      # Generate an array of arrays - the inner array lists all branches that contain
      # each of the SHAs listed above
      contains_info = shas.map do |sha|
        `git branch -a --contains #{sha}`.split
      end

      staged_branches = Set.new

      contains_info.each do |branches|
        branches.each do |branch|
          # First, sanitize
          branch.gsub!('remotes/origin/', '')

          # Only match branch names that start with a digit (we're assuming
          # that these all reference tickets)
          staged_branches << branch if branch =~ /^\d+/
        end
      end

      tickets = staged_branches.to_a.map(&:to_i)
      puts "Staged: #{tickets.join(',')}"

      tickets
    end

    def move_staged_tickets
      unless projects.one?
        puts "Please specify one project!"
        return
      end

      # Grab the actual lighthouse project
      project = projects.first

      tickets = project.find_tickets(*list_staged_tickets)
      tickets.each do |ticket|
        unless ticket.state == 'verified'
          ticket.state = @options[:to_state]
          ticket.save
        end
      end
    end
    
    def summary
      body = ''
      
      projects.each do |project|
        bin = project.bins.detect {|b| b.name =~ /^#{Regexp.escape(@options[:bin_name])}$/i}
        
        unless bin
          puts "No ticket bin found matching \"#{@options[:bin_name]}\" in #{project.name}"
          next 
        end
        
        tickets = bin.tickets.sort_by(&:id)
        
        body << "=== #{project.name} ===\n\n" if tickets.length > 0
        
        tickets.each do |ticket|
          body << title = "##{ticket.number} - #{ticket.title}\n"
          body << "-" * title.length + "\n\n"
          
          if ticket.original_body.to_s.strip.empty?
            body << "(no description)" + "\n" * 4
          else
            body << "#{ticket.original_body}"  + "\n" * 4
          end
          
        end
      end
      
      puts body
      
      `echo "#{body.gsub('"', '\"')}" | pbcopy`
      puts "Summary copied to the clipboard"
    end
    
    def refresh!
      projects.each(&:refresh!)
    end
    
    def self.load_config
      YAML.load_file(File.expand_path('~/.buildmeister_config.yml'))
    end
  end
end
