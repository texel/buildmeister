# Wraps Lighthouse::Bin and keeps track of state

module Buildmeister
  class Bin
    attr_accessor :bin, :mode, :value, :last_value
    
    def initialize(bin, mode = :verbose)
      self.bin  = bin
      self.mode = mode
      
      refresh!
    end
    
    def refresh!
      self.last_value = value
      
      case mode
      when :verbose
        self.value = bin.tickets.map(&:id).join(', ')
      end
    end
    
    def changed?
      value != last_value
    end
  end
end