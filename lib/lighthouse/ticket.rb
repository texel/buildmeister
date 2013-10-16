module Lighthouse
  class Ticket
    attr_reader :id, :name, :state

    def initialize(attrs)
      @id    = attrs['number']
      @name  = attrs['name']
      @tag   = attrs['tag']
      @state = attrs['state']
    end

    def tags
      (@tag || '').split(',')
    end
  end
end
