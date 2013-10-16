module Lighthouse
  class Ticket
    attr_reader :id, :name

    def initialize(attrs)
      @id = attrs['number']      
      @name = attrs['name']
      @tag = attrs['tag']
    end

    def tags
      (@tag || '').split(',')
    end
  end
end
