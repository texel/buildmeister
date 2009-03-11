require 'rubygems'
require 'lighthouse'

class Buildmeister
  VERSION   = '1.0.0'
  BIN_NAMES = %w(ready staged verified ready_experimental staged_experimental verified_experimental)
  
  attr_accessor :project, :project_name
  
  BIN_NAMES.each do |bin_name|
    attr_accessor :"#{bin_name}", :"last_#{bin_name}"
  end
  
  def initialize(project_name)
    @config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '~/.buildmeister_config.yml'))
    Lighthouse.account = @config['account']
    Lighthouse.token   = @config['token']
    self.project_name = project_name
    self.get_project
        
    self.load_project
  end
  
  def move_all(bin_name, options)
    self.send(bin_name).tickets.each do |ticket|
      ticket.state = options[:to_state]
      ticket.save
    end
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
    
    self.ready     = bins.find { |bin| bin.name == 'Ready'     }
    self.staged    = bins.find { |bin| bin.name == 'Staged'    }
    self.verified  = bins.find { |bin| bin.name == 'Verified'  }
    
    self.ready_experimental     = bins.find { |bin| bin.name == 'Ready (Experimental)'   }
    self.staged_experimental    = bins.find { |bin| bin.name == 'Staged (Experimental)'  }
    self.verified_experimental  = bins.find { |bin| bin.name == 'Verified (Experimental)'  }
  end
  
  def reload_info
    BIN_NAMES.each do |bin_name|
      send("last_#{bin_name}=", send(bin_name).tickets_count)
    end
    
    self.load_project
    
   BIN_NAMES.each do |state|
      self.send(state).reload
    end
  end
  
  def changed?
    BIN_NAMES.map { |bin_name| self.send(bin_name).tickets_count } != BIN_NAMES.map { |bin_name| send("last_#{bin_name}") }
  end
  
  def get_project
    projects = Lighthouse::Project.find(:all)
    self.project  = projects.find {|pr| pr.name == project_name}
  end
end