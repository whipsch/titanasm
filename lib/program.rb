module Titan
  class Program
    def self.const_missing(name)
      # registers
      if name.to_s =~ /^R([0-9A-F])$/
        $1.to_i(16) 
      end
    end

    attr_reader :instructions
    attr_reader :current_address

    def initialize(str = nil, filename = nil, &block)
      @instructions = []
      @labels = {}
      @current_address = 0
      
      instance_eval(str, filename) if str
      instance_eval(&block) if block_given?
    end

    def [](label)
      @labels[label]
    end

    def set_label(label, address)
      raise RuntimeError.new("tried to redefine existing label %s@0x%04X to 0x%04X" % [label, @labels[label], address]) if @labels[label]

      @labels[label] = address
    end

    def method_missing(name, *args, &block)
      # TODO
    end

    def assemble
      # TODO
    end
  end
end
