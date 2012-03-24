module Titan
  class Program
    def self.const_missing(name)
      # registers
      if name.to_s =~ /^R([0-9A-F])$/
        $1.to_i(16) 
      end
    end

    attr_reader :labels
    attr_reader :instructions

    def initialize(str = nil, filename = nil, &block)
      @instructions = []
      @labels = {}
      @current_address = 0
      
      instance_eval(str, filename) if str
      instance_eval(&block) if block_given?
    end

    def push_instruction(ins)
      @current_address += instruction_width(ins)
      @instructions << ins
    end

    def instruction_width(ins)
      case ins[0]
      when 0, 0xA6      # NOP, RTN
        1
      when 0x10..0x20   # arithmetic, INT
        2
      when 0x70..0x8F   # PSH, POP
        1
      when 0x90..0x92   # registers
        2
      when 0xA0..0xA5,
           0xA8, 0xA9   # jumps
        3
      else
        1
      end
    end

    def emit(b)
      if b.is_a? String
        b
      elsif b.is_a? Array
        b.pack('a*')
      elsif b.is_a? Symbol
        [@labels[b]].pack('n')
      else
        [b].pack('C')
      end
    end

    def label(l)
      @labels[l] = @current_address
    end

    def assemble
      @instructions.map do |ins|
        ins.map { |v| emit v }.join
      end.join
    end
    

    def nop
      push_instruction [0]
    end

    # arithmetic instructions
    def add(src, dst)
      push_instruction [0x10, (src << 4) | dst]
    end

    def adc(src, dst)
      push_instruction [0x11, (src << 4) | dst]
    end

    def sub(src, dst)
      push_instruction [0x12, (src << 4) | dst]
    end

    def and(src, dst)
      push_instruction [0x13, (src << 4) | dst]
    end

    def lor(src, dst)
      push_instruction [0x14, (src << 4) | dst]
    end

    def xor(src, dst)
      push_instruction [0x15, (src << 4) | dst]
    end

    def not(src)
      # TODO: make sure this is correct
      push_instruction [0x16, src]
    end

    def shr(src)
      # TODO: make sure this is correct
      push_instruction [0x17, src]
    end


    # interrupt/exception
    def int(idx)
      push_instruction [0x20, idx]
    end

    def rte
      # TODO
    end


    # stack
    def psh(src)
      push_instruction [0x70 | src]
    end

    def pop(src)
      push_instruction [0x80 | src]
    end


    # register ops
    def mov(src, dst)
      push_instruction [0x90, (src << 4) | dst]
    end

    def clr(reg)
      push_instruction [0x91, reg]
    end

    def xch(src, dst)
      push_instruction [0x92, (src << 4) | dst]
    end


    # direct jumps
    def jmp(target)
      push_instruction [0xA0, target]
    end

    def jpz(target)
      push_instruction [0xA1, target]
    end

    def jps(target)
      push_instruction [0xA2, target]
    end

    def jpc(target)
      push_instruction [0xA3, target]
    end

    def jpi(target)
      push_instruction [0xA4, target]
    end

    def jsr(target)
      push_instruction [0xA5, target]
    end

    def rtn
      push_instruction [0xA6]
    end

    def jmi(target)
      if target.is_a? Array
        push_instruction [0xA8, target[0], target[1]]
      else
        push_instruction [0xA9, target]
      end
    end

    
    # indexed memory
    def ldi(reg, target)
      if target.is_a? Array
        push_instruction [0xB8 | reg, target[0], target[1]]
      else
        push_instruction [0xB0 | reg, target]
      end
    end

    def sti(reg, target)
      if target.is_a? Array
        push_instruction [0xC8 | reg, target[0], target[1]]
      else
        push_instruction [0xC0 | reg, target]
      end
    end


    def ldc(reg, value)
      push_instruction [0xD0 | reg, value]
    end


    # load/store
    def ldm(reg, target)
      push_instruction [0xE0 | reg, target >> 8, target & 0xFF]
    end

    def stm(reg, target)
      push_instruction [0xF0 | reg, target >> 8, target & 0xFF]
    end


    # other stuff
    def str(l, s)
      label(l)
      push_instruction [s]
    end

    def str0(l, s)
      str(l, "#{s}\x00")
    end

    def byte(l, v)
      label(l)
      push_instruction [v]
    end

    def word(l, v)
      label(l)
      push_instruction [v >> 8]
      push_instruction [v & 0xFF]
    end

    def data(l, d)
      label(l)
      push_instruction [d]
    end
  end
end
