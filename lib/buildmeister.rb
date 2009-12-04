require 'rubygems'
require 'lighthouse'
require 'activesupport'
require 'optparse'

class Buildmeister
  attr_accessor :project, :project_name, :bin_groups, :notification_interval
  
  RETRY_COUNT = 5
  
  def initialize
    @options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: buildmeister notify"

      opts.on('-f', '--from-bin BIN_NAME', 'Move From Bin') do |f|
        @options[:move_from] = f
      end

      opts.on('-t', '--to-state STATE', 'Move to State') do |t|
        @options[:to_state] = t
      end
      
      opts.on('-v', '--verbose', 'Verbose') do |t|
        @options[:verbose] = true
      end
    end.parse!
    
    @config = Buildmeister.load_config
    Lighthouse.account  = @config['account']
    Lighthouse.token    = @config['token']
    
    self.project_name   = @config['project_name']
    self.get_project
    self.bin_groups     = []
    
    self.notification_interval = @config['notification_interval']
    
    @config['bin_groups'].each do |bin_group|
      self.bin_groups << {
        :name       => bin_group.keys.first,
        :bin_names  => bin_group.values.first.map
      }
    end
    
    self.bin_groups.each do |bin_group|
      bin_group[:bin_names].each do |bin_name|
        class << bin_name
          def normalize
            Buildmeister.normalize_bin_name(self)
          end
        end
        
        attr_accessor_init = <<-eos
          class << self
            attr_accessor :"#{bin_name.normalize}", :"last_#{bin_name.normalize}"
          end
        eos
        
        eval attr_accessor_init
      end
    end
        
    load_project
  end
  
  def normalize(bin_name)
    Buildmeister.normalize_bin_name(bin_name)
  end
  
  def new_hotfix
    generate_timed_branch('hotfix')
  end
  
  def new_experimental
    generate_timed_branch('experimental')
  end
  
  def generate_timed_branch(prefix)
    branches = local_branches
    now      = Time.now
    count    = 1
    
    loop do
      new_branch_name = "#{prefix}-#{now.year}-#{now.month.to_s.rjust 2, '0'}-#{now.day.to_s.rjust 2, '0'}-#{count.to_s.rjust 3, '0'}"
      unless branches.include? new_branch_name
        `git checkout -b #{new_branch_name}`
        puts "Created #{new_branch_name}"
        return true
      end
      
      count += 1
    end
  end
  
  def pull_bin(bin_name = ARGV.shift)
    bin_name            = normalize(bin_name)
    existing_bin_names  = bin_names.map { |b| b.normalize }
    
    raise ArgumentError, "#{bin_name} is not a valid bin! Must be in #{bin_names.join(', ')}" unless existing_bin_names.include?(bin_name)
    
    `git fetch origin`
    
    branches        = remote_branches
    ticket_numbers  = send(normalize(bin_name)).tickets.map { |tkt| tkt.id.to_s }
    
    branches_to_pull = branches.select do |branch_name|
      ticket_numbers.map { |tkt_number| branch_name =~ /#{tkt_number}/ }.any?
    end
    
    branches_to_pull.each do |branch|
      result = `git pull origin #{branch.gsub("origin/", "")}`
      puts result
    end
  end
  
  def local_branches
    `git branch`.split.reject { |name| name == "*" }
  end
  
  def remote_branches
    `git branch -r`.split.reject { |name| name == "*" }
  end
  
  def current_branch
    branches = `git branch`.split
    i = branches.index "*"
    branches[i + 1]
  end
  
  def move_all
    bin_name = normalize @options[:move_from]
    self.send(bin_name).tickets.each do |ticket|
      ticket.state = @options[:to_state]
      ticket.save
    end
    
    puts "All tickets from bin #{@options[:move_from]} have been moved to #{@options[:to_state]}"
  end
  
  def bin_group_report(bin_group_name = normalize(ARGV.shift))
    bin_group = bin_groups.find { |group| group[:name] == bin_group_name }
    bin_names = bin_group[:bin_names].map &:normalize
    
    ticket_numbers = bin_names.map do |bin_name|
      send(normalize(bin_name)).tickets.map &:id
    end.flatten
    
    # Pluck the relevant branch names using git...
    relevant_branches = 
      remote_branches.select do |branch_name|
        ticket_numbers.map { |tkt_number| branch_name =~ /#{tkt_number}/ }.any?
      end.map { |b| b.gsub('origin/', '') }
      
    output = ""
    output << "#{current_branch}\n"
    relevant_branches.each do |branch|
      output << "\n#{branch}"
    end
    
    puts output
  end
  
  def resolve_verified
    self.verified.tickets.each do |ticket|
      ticket.state = 'resolved'
      ticket.save
    end
  end
  
  def stage_all
    self.ready.tickets.each do |ticket|
      ticket.state = 'staged'
      ticket.save
    end
  end
  
  def load_project
    bins  = self.get_project.bins
    
    self.bin_groups.each do |bin_group|
      bin_group[:bin_names].each do |bin_name|
        self.send("#{bin_name.normalize}=", bins.find { |bin| bin.name == bin_name })
        
        class << self.send("#{bin_name.normalize}")
          attr_accessor :display_value
        end
      end
    end
  end
  
  def reload_info
    bin_names.each do |bin_name|
      send("last_#{bin_name.normalize}=", display_value(bin_name))
    end

    self.load_project
  end
  
  def bin_names
    bin_groups.map do |bin_group|
      bin_group[:bin_names].map do |bin_name|
        bin_name
      end
    end.flatten
  end
  
  def changed?
    bin_names.map { |bin_name| display_value(bin_name) } != bin_names.map { |bin_name| send("last_#{bin_name.normalize}") }
  end
  
  def get_project
    self.project ||= Lighthouse::Project.find(:all).find {|pr| pr.name == project_name}
  end
  
  def notify
    puts "Starting BuildMeister Notify..."
    
    retry_count = RETRY_COUNT
    
    loop do
      begin
        title = "BuildMeister: #{Time.now.strftime("%m/%d %I:%M %p")}"

        body = ''

        bin_groups.each do |bin_group|
          body += "#{bin_group[:name].titleize}\n"
          body += "---------\n"

          bin_group[:bin_names].each do |bin_name|
            body += "#{bin_name}: #{display_value(bin_name)}\n"
          end

          body += "\n"
        end

        puts "Updated notification at #{Time.now.strftime("%m/%d %I:%M %p")}"

        if changed?
          Buildmeister.post_notification(title, body)   
        end

        sleep notification_interval.minutes.to_i

        reload_info
      rescue StandardError => e        
        if retry_count < 1
          puts "Retried #{RETRY_COUNT} times... I give up!"
          raise e
        else
          # Exponential falloff...
          sleep_time = 50 * (1 / (retry_count / 2))
          
          puts "Caught error: #{e.class.name}: #{e.message}"
          puts "#{retry_count} more tries... sleeping #{sleep_time} seconds..."
          
          sleep sleep_time
          
          retry_count -= 1
          
          retry
        end
      end
    end
  end
  
  def display_value(bin_name)
    # We're memoizing the display value on the bin objects
    # so that when it comes time to reload, the previous value
    # is kept.
    send(bin_name.normalize).display_value ||=
      if @options[:verbose]
        send(bin_name.normalize).tickets.map(&:id).join(", ")
      else
        send(bin_name.normalize).tickets_count
      end
  end
  
  def git_cleanup
    
  end
  
  # -----------------------------------------
  # Class Methods
  # -----------------------------------------
  
  def self.post_notification(title, body)
    `growlnotify -H localhost -s -n "Buildmeister" -d "Buildmeister" -t #{title} -m "#{body}"`
  end
  
  def self.normalize_bin_name(bin_name)
    bin_name.squeeze(' ').gsub(' ', '_').gsub(/\W/, '').downcase
  end
  
  def self.load_config
    YAML.load_file(File.expand_path('~/.buildmeister_config.yml'))
  end
end