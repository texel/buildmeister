require 'rubygems'
require 'lighthouse'

class Buildmeister
  VERSION = '1.0.0'
  
  attr_accessor :project, :project_name,
                :ready, :staged, :verified, :ready_experimental, :staged_experimental,
                :last_ready, :last_staged, :last_verified
  
  def initialize(project_name)
    @config = YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/../config/config.yml'))
    Lighthouse.account = @config['account']
    Lighthouse.token   = @config['token']
    self.project_name = project_name
    self.get_project
        
    self.load_project
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
    
    self.ready_experimental  = bins.find { |bin| bin.name == 'Ready (Experimental)'   }
    self.staged_experimental = bins.find { |bin| bin.name == 'Staged (Experimental)'  }
  end
  
  def reload_info
    self.last_ready, self.last_staged, self.last_verified = self.ready.tickets_count, self.staged.tickets_count, self.verified.tickets_count
    
    self.load_project
    
    # %w(ready staged verified).each do |state|
    #   self.send(state).reload
    # end
    
    self.ready.reload
    self.staged.reload
    self.verified.reload
  end
  
  def changed?
    [ready.tickets_count, staged.tickets_count, verified.tickets_count] != [last_ready, last_staged, last_verified]
  end
  
  def get_project
    projects = Lighthouse::Project.find(:all)
    self.project  = projects.find {|pr| pr.name == project_name}
  end
end