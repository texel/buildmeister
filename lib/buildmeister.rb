require 'rubygems'
require 'lighthouse'
require 'activesupport'
require 'optparse'

class Buildmeister
  attr_accessor :project, :project_name, :bin_groups, :notification_interval
  
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
        
    self.load_project
  end
  
  def move_all
    bin_name = Buildmeister.normalize_bin_name @options[:move_from]
    self.send(bin_name).tickets.each do |ticket|
      ticket.state = @options[:to_state]
      ticket.save
    end
    
    puts "All tickets from bin #{@options[:move_from]} have been moved to #{@options[:to_state]}"
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
      end
    end
  end
  
  def reload_info
    bin_names.each do |bin_name|
      send("last_#{bin_name.normalize}=", send(bin_name.normalize).tickets_count)
    end

    self.load_project
    
    bin_names.each do |bin_name|
      self.send(bin_name.normalize).reload
    end
  end
  
  def bin_names
    bin_groups.map do |bin_group|
      bin_group[:bin_names].map do |bin_name|
        bin_name
      end
    end.flatten
  end
  
  def changed?
    bin_names.map { |bin_name| self.send(bin_name.normalize).tickets_count } != bin_names.map { |bin_name| send("last_#{bin_name.normalize}") }
  end
  
  def get_project
    projects = Lighthouse::Project.find(:all)
    self.project  = projects.find {|pr| pr.name == project_name}
  end
  
  def notify
    puts "Starting BuildMeister Notify..."

    while true do  
      title = "BuildMeister: #{Time.now.strftime("%m/%d %I:%M %p")}"

      body = ''

      bin_groups.each do |bin_group|
        body += "#{bin_group[:name].titleize}\n"
        body += "---------\n"

        bin_group[:bin_names].each do |bin_name|
          if @options[:verbose]
            display_value = send(bin_name.normalize).tickets.map(&:id).join(", ")
          else
            display_value = send(bin_name.normalize).tickets_count
          end
          body += "#{bin_name}: #{display_value}\n"
        end

        body += "\n"
      end

      puts "Updated notification at #{Time.now.strftime("%m/%d %I:%M %p")}"

      if changed?
        Buildmeister.post_notification(title, body)   
      end

      sleep notification_interval.minutes.to_i

      reload_info
    end
  end
  
  def git_cleanup
    
  end
  
  # -----------------------------------------
  # Class Methods
  # -----------------------------------------
  
  def self.post_notification(title, body)
    `growlnotify -s -n "Buildmeister" -d "Buildmeister" -t #{title} -m "#{body}"`
  end
  
  def self.normalize_bin_name(bin_name)
    bin_name.squeeze(' ').gsub(' ', '_').gsub(/\W/, '').downcase
  end
  
  def self.load_config
    YAML.load_file(File.expand_path('~/.buildmeister_config.yml'))
  end
end