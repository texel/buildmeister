module Buildmeister
  module Finder    
    def named(name)
      find { |e| e.name == name}
    end
  end
end