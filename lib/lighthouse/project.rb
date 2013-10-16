module Lighthouse
  class Project
    include Buildmeister::StringUtils
    include Buildmeister::JSONUtils
    
    attr_accessor :id, :name, :resource
        
    def initialize(resource, attributes)
      @id   = attributes['id']
      @name = attributes['name']

      @resource = resource

      # self.bins = []
      
      # bins.extend Finder
      
      # project_bins = bins

      # config['bins'].each do |bin_name|
        # bin = project_bins.find { |b| b.name == bin_name }
        # raise "No bin named #{bin_name}" unless bin 
        
        # bins << Buildmeister::Bin.new(bin, options[:mode], :annotations => config['annotations'])
      # end
      
      # config['personal_bins'].each do |bin_name|
        # bin = project_bins.find { |b| !b.shared && (b.name == bin_name) }
        # raise "No bin named #{bin_name}" unless bin 
        
        # bins << Buildmeister::Bin.new(bin, options[:mode], :annotations => config['annotations'])
      # end if config['personal_bins']
    end

    def bins
      with_json_response( bins_resource.get(accept: 'json') ) do |r|
        r['ticket_bins'].map do |b|
          attrs = b['ticket_bin']

          Lighthouse::Bin.new(self, attrs)
        end
      end.tap { |a| a.extend(Buildmeister::Finder) }
    end

    def tickets(query = "")
      with_json_response( tickets_resource.get(params: {q: query}, accept: 'json') ) do |r|
        (r['tickets'] || []).map do |t|
          attrs = t['ticket']  
          
          Lighthouse::Ticket.new(attrs)
        end
      end
    end

    # There's no good way to do this in the Lighthouse API. This is slow, but at least it's
    # easy to write.
    def find_tickets(*ids)
      ids.map do |id|
        project.tickets(:q => id).first
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
      bins.each(&:refresh!)
    end
    
    def changed?
      bins.any?(&:changed?)
    end

    private

    def bins_resource
      @bins_resource ||= resource['bins']
    end

    def tickets_resource
      @tickets_resource ||= resource['tickets']
    end
  end
end
