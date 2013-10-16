module Lighthouse
  class Bin
    attr_reader :id, :name, :query, :tickets_count

    def initialize(tickets_resource, attrs)
      @tickets_resource = tickets_resource

      @name  = attrs['name']
      @id    = attrs['id']
      @query = attrs['query']

      @tickets_count = attrs['tickets_count']
    end

    def tickets
      @tickets_resource.get(params: {q: @query}, accept: 'json')  
    end
  end
end

