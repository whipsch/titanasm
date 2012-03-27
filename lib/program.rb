module Titan
  class Program
    include Util

    # TODO: move this or do it a different way
    def self.const_missing(name)
      # registers
      if name.to_s =~ /^R([0-9A-F])$/
        $1.to_i(16) 
      else
        super
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
      name = name.to_s.sub(/_$/, '').to_sym if name =~ /_$/

      if ins_def = INSTRUCTIONS[name]
        eval_instruction(name, ins_def, args, :pre) if produces_label?(name, args)
        @current_address += instruction_length(ins_def, args)
        @instructions << args.unshift(name)
      else
        super
      end
    end

    def instruction_length(ins_def, args)
      len = ins_def[0] ? 1 : 0  # does this instruction have an opcode?

      len + (ins_def[1].is_a?(Proc) ? ins_def[1].call(args) : ins_def[1])
    end

    def eval_instruction(name, ins_def, args, mode)
      if ins_def.length == 4
        em = ins_def[3]
        em = EMITTERS[em] if em.is_a?(Symbol)

        op = ins_def[0]
        op = op.call(args) if op.is_a?(Proc)

        return em.call(mode, name, op, args, self) 
      end

      ''
    end

    def assemble(mode)
      indent = ''

      @instructions.reduce('') do |acc, ins|
        name = ins[0]
        ins_def = INSTRUCTIONS[name]

        indent = '' if mode == :asm_src && name == :label
        
        output = eval_instruction(name, ins_def, ins[1..-1], mode)
        acc += indent + output

        if mode == :asm_src
          indent = '  ' if name == :label
          acc += "\n" if output != ''
        end
        
        acc
      end
    end
  end
end
