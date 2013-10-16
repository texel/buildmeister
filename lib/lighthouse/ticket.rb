module Lighthouse
  class Ticket
    attr_reader :id, :name

    def initialize(attrs)
      @id = attrs['id']      
      @name = attrs['name']
    end
  end
end
