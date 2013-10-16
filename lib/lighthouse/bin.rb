module Lighthouse
  class Bin
    include Buildmeister::JSONUtils

    attr_reader :id, :name, :query, :tickets_count

    def initialize(project, attrs)
      @project = project

      @name  = attrs['name']
      @id    = attrs['id']
      @query = attrs['query']

      @tickets_count = attrs['tickets_count']
    end

    def tickets
      @project.tickets(@query)
    end
  end
end

