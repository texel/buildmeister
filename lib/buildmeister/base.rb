require 'optparse'

module Buildmeister
  class Base
    include StringUtils
    include GitUtils
    
    RETRY_COUNT = 5
    
    attr_accessor :projects, :notification_interval, :command, :args
    
    def initialize(*args)
      self.args = args
      
      @options  = {:mode => :verbose}
            
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
        
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
        
        if args.empty?
          puts opts
          exit
        end
      end.parse!(args)
      
      # Lighthouse setup
      @config = Buildmeister::Base.load_config
      
      Lighthouse.account = @config['account']
      Lighthouse.token   = @config['token']
      
      self.projects = []
      
      projects.extend Finder
      
      if @options[:project]
        @config['projects'] = @config['projects'].select { |p| p['name'] == @options[:project] } 
        raise "#{@options[:project]} did not match any projects in the config file" if @config['projects'].blank?
      end
      
      @config['projects'].each do |project|
        self.projects << Buildmeister::Project.new(project, @options)
      end
      
      self.notification_interval = @config['notification_interval']
      
      # Did we pass in a command?
      self.command = args.shift      
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

          sleep notification_interval.minutes.to_i

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
    
    def refresh!
      projects.each(&:refresh!)
    end
    
    def self.load_config
      YAML.load_file(File.expand_path('~/.buildmeister_config.yml'))
    end
  end
end
