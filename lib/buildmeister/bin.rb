# Wraps Lighthouse::Bin and keeps track of state

module Buildmeister
  class Bin
    attr_accessor :bin, :mode, :value, :last_value
    
    delegate :name, :tickets, :to => :bin
    
    def initialize(lighthouse_bin, mode = :verbose)
      self.bin  = lighthouse_bin
      self.mode = mode
      
      refresh!
    end
    
    def refresh!
      self.last_value = value
      
      case mode
      when :verbose
        self.value = bin.tickets.map(&:id).join(', ')
      when :quiet
        self.value = bin.tickets_count
      end
    end
    
    def display
      "#{name}: #{value}"
    end
    
    def changed?
      value != last_value
    end
  end
end