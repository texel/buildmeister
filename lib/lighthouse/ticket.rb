module Lighthouse
  class Ticket
    attr_reader :id, :name
    attr_accessor :state

    def initialize(resource, attrs)
      @resource = resource

      @id    = attrs['number']
      @name  = attrs['name']
      @tag   = attrs['tag']
      @state = attrs['state']
    end

    def tags
      (@tag || '').split(',')
    end

    # For now, only allow state update
    def to_json
      {ticket: {
        state: @state
      }}
    end

    def save
      @resource.put(to_json, content_type: 'text/json', accept: 'json')
    end
  end
end
