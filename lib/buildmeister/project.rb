module Buildmeister
  class Project
    include StringUtils
    
    attr_accessor :project, :name, :bins
        
    def initialize(config, lighthouse_account, options = {})
      self.name = config['name']
      self.bins = []
      
      bins.extend Finder
      
      self.project = lighthouse_account.projects.named(name)

      project_bins = project.bins

      config['bins'].each do |bin_name|
        bin = project_bins.find { |b| b.name == bin_name }
        raise "No bin named #{bin_name}" unless bin 
        
        bins << Buildmeister::Bin.new(bin, options[:mode], :annotations => config['annotations'])
      end
      
      config['personal_bins'].each do |bin_name|
        bin = project_bins.find { |b| !b.shared && (b.name == bin_name) }
        raise "No bin named #{bin_name}" unless bin 
        
        bins << Buildmeister::Bin.new(bin, options[:mode], :annotations => config['annotations'])
      end if config['personal_bins']
    end

    # There's no good way to do this in the Lighthouse API. This is slow, but at least it's
    # easy to write.
    def find_tickets(*ids)
      ids.map do |id|
        project.tickets(id).first
      end.compact
    end
    
    def display
      out = ''
      out << name + "\n"
      out << "#{divider}\n"
      
      bins.each do |bin|
        out << bin.display + "\n"
      end
      
      out
    end
    
    def refresh!
      bins.each &:refresh!
    end
    
    def changed?
      bins.any? &:changed?
    end
  end
end
