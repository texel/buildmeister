# Wraps Lighthouse::Bin and keeps track of state

module Buildmeister
  class Bin
    attr_accessor :bin, :mode, :value, :last_value, :annotations
    
    delegate :name, :tickets, :to => :bin
    
    def initialize(lighthouse_bin, mode = :verbose, options = {})
      self.bin  = lighthouse_bin
      self.mode = mode
      self.annotations = options[:annotations] || {}
      
      refresh!
    end
    
    def refresh!
      self.last_value = value
      
      case mode
      when :verbose
        self.value = bin.tickets.map do |tkt|
          str =  "#{tkt.id}"
          annotations.each do |tag_name, identifier|
            str << identifier if tkt.tags.include?(tag_name)
          end
          str
        end.join(', ')
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