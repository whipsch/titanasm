module Titan
  EMITTERS = {
    # arithmetic
    :art_main   => Proc.new { |mode, name, opcode, params, program|
      case mode
      when :assemble
        [opcode, ((params[0] & 0x0F) << 4) | (params[1] & 0x0F)].pack('CC')
      when :asm_src
        "%s R%X,R%X" % params.unshift(name.upcase)
      end
    },
    :art_alt    => Proc.new { |mode, name, opcode, params, program|
      case mode
      when :assemble
        [opcode, (params[0] & 0x0F) << 4].pack('CC')
      when :asm_src
        "%s R%X" % params.unshift(name.upcase)
      end
    },
    :art_p1_dup => Proc.new { |mode, name, opcode, params, program|
      case mode
      when :assemble
        [opcode, ((params[0] & 0x0F) << 4) | (params[0] & 0x0F)].pack('CC')
      when :asm_src
        "%s R%X" % params.unshift(name.upcase)
      end
    },

    # generic
    :gen_p1_a   => Proc.new { |mode, name, opcode, params, program|
      case mode
      when :assemble
        [opcode, params[0] & 0xFF].pack('CC')
      when :asm_src
        "%s 0x%02X" % params.unshift(name.upcase)
      end
    },
    :gen_p2_a   => Proc.new { |mode, name, opcode, params, program|
      case mode
      when :assemble
        params[0] = program[params[0]] if params[0].is_a? Symbol
        [opcode, params[0]].pack('Cn') 
      when :asm_src
        fmt = params[0].is_a? Symbol ? "%s %s" : "%s 0x%04X"
        fmt % params.unshift(name.upcase)
      end
    },
    :gen_split1 => Proc.new { |mode, name, opcode, params, program|
      case mode
      when :assemble
        [opcode, ((params[0] & 0x0F) << 4) | (params[1] & 0x0F)].pack('CC')
      when :asm_src
        "%s R%X,R%X" % params.unshift(name.upcase)
      end
    },

    # ldi/sti
    :ldi_sti => Proc.new { |mode, name, opcode, params, program|
      case mode
      when :assemble
        if params[1].is_a? Array
          [opcode, params[0], ((params[1][0] & 0x0F) << 4) | (params[1][1] & 0x0F)].pack('CC')
        else
          params.unshift(opcode).pack('Cn')
        end
      when :asm_src
        if params[1].is_a? Array
          "%s R%X,[R%X,R%X]" % [name.upcase, params[0], params[1][0], params[1][1]]
        else
          "%s R%x,0x%04X" % params.unshift(name.upcase)
        end
      end
    },

    # data directives
    :data_lbl_1 => Proc.new { |mode, name, opcode, params, program|
      raise RuntimeError.new("#{name}: expected 1 or 2 parameters, received #{params.length}") if params.length != 1 && params.length != 2

      case mode
      when :assemble
        if params.length == 1
          params.pack('C')
        else
          program.set_label(params[1], program.current_address)
          [params[1]].pack('C')
        end
      when :asm_src
        fmt = params.length == 1 ? ".%s 0x%02X" : ".%s %s 0x%02X"
        fmt % params.unshift(name.upcase)
      end
    },
    :data_lbl_2 => Proc.new { |mode, name, opcode, params, program|
      raise RuntimeError.new("#{name}: expected 1 or 2 parameters, received #{params.length}") if params.length != 1 && params.length != 2

      case mode
      when :assemble
        if params.length == 1
          params.pack('n')
        else
          program.set_label(params[0], params[1])
          ''
        end
      when :asm_src
        fmt = params.length == 1 ? ".%s 0x%04X" : ".%s %s 0x%04X"
        fmt % params.unshift(name.upcase)
      end
    },
    :data_lbl_a => Proc.new { |mode, name, opcode, params, program|
      raise RuntimeError.new("#{name}: expected 1 or more arguments, received 0") if params.empty?
      raise RuntimeError.new("#{name}: expected Symbol, received #{params[0].class}") if params.length > 1 && !params[0].is_a?(Symbol)

      case mode
      when :assemble
        if params.length > 1
          program.set_label(params.slice!(1), program.current_address)
        end

        if params.length == 1
          if params[0].is_a? String
            [opcode].pack('C') << params[0]
          elsif params[0].is_a? Fixnum
            params.unshift(opcode).pack('C*')
          else
            raise RuntimeError.new("#{name}: expected String or Fixnum, received #{params[0].class}")
          end
        else
          params.slice(1..-1).reduce([opcode].pack('C')) { |acc, p|
            acc << p.is_a? Fixnum ? [p].pack('C') : p
          }
        end
      when :asm_src
        # holy hack watman!
        ".#{name.upcase} " << (params.each do |p|
          if p.is_a? Fixnum
            '0x%02X' % [p]
          else
            (['0x%02X'] * p.length).join(' ') % p.is_a? String ? p.split('').map(&:ord) : p
        end).join(' ')
      end
    },
    :data_lbl_s => Proc.new { |mode, name, opcode, params, program|
      raise RuntimeError.new("#{name}: expected 1 or 2 arguments, received #{params.length}") if params.length != 1 && params.length != 2 
      raise RuntimeError.new("#{name}: expected Symbol, received #{params[0].class}") if params.length > 1 && !params[0].is_a?(Symbol)

      case mode
      when :assemble
        if params.length > 1
          program.set_label(params.slice!(1), program.current_address)
        end

        params.join('')
      when :asm_src
        params.length > 1 ? '.%s %s "%s"' % [name.upcase, params.slice!(1), params.join]
                          : '.%s "%s"' % [name.upcase, params.join]
      end
    },
    :data_lbl_z => Proc.new { |mode, name, opcode, params, program|
      raise RuntimeError.new("#{name}: expected 1 or 2 arguments, received #{params.length}") if params.length != 1 && params.length != 2 
      raise RuntimeError.new("#{name}: expected Symbol, received #{params[0].class}") if params.length > 1 && !params[0].is_a?(Symbol)

      case mode
      when :assemble
        if params.length > 1
          program.set_label(params.slice!(1), program.current_address)
        end

        params.join('') << "\x00"
      when :asm_src
        params.length > 1 ? '.%s %s "%s"' % [name.upcase, params.slice!(1), params.join]
                          : '.%s "%s"' % [name.upcase, params.join]
      end
    },

    # asm directives
    :asm_incl => Proc.new { |mode, name, opcode, params, program|
      # TODO
    },
    :asm_orgg => Proc.new { |mode, name, opcode, params, program|
      # TODO
    }
  }
end
