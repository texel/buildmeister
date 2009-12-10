module Buildmeister
  module Finder
    def [](name)      
      case name
      when String, Symbol
        find { |e| e.name == name }
      when Integer
        super
      end
    end
  end
end