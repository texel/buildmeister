module Buildmeister
  class Project
    attr_accessor :project, :name, :bins
    
    def initialize(config)
      self.name = config['name']
      self.bins = []

      config['bins'].each do |bin|
        bins << bin
      end
    end
  end
end