module Buildmeister
  module Finder    
    def named(name)
      find_where(name: name)
    end

    def find_where(attrs)
      find do |o|
        attrs.all? do |name, value|
          o.send(name) == value
        end
      end
    end
  end
end
