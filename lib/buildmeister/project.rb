module Buildmeister
  class Project
    include StringUtils
    
    attr_accessor :project, :name, :bins
        
    def initialize(config, options = {})
      self.name = config['name']
      self.bins = []
      
      bins.extend Finder
      
      self.project = Lighthouse::Project.find(:all).find { |p| p.name == self.name }

      project_bins = project.bins

      config['bins'].each do |bin_name|
        bin = project_bins.find { |b| b.name == bin_name }
        raise "No bin named #{bin_name}" unless bin 
        
        bins << Buildmeister::Bin.new(bin, options[:mode])
      end
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