module Titan
  # variable opcode procs
  op_low_fp       = Proc.new { |base, params| base | (params[0] & 0x0F) }
  op_ldi_sti_type = Proc.new { |base, params|
    base += 0x10 unless params.is_a?(Array)
    base | (params[0] & 0x07)
  }

  # variable length procs
  len_p1_type = Proc.new { |params| params[0].is_a?(Array) ? 1 : 2 }
  len_p2_type = Proc.new { |params| params[1].is_a?(Array) ? 1 : 2 }
  len_asm_word = Proc.new { |params| params.length == 1 ? 2 : 0 }
  len_asm_data = Proc.new { |params|
    if params.length == 2
      params[1].is_a?(Fixnum) ? 1 : params[1].length
    else
      params.length
    end
  }
  len_asm_asci = Proc.new { |params| params[1].length }
  len_asm_ascz = Proc.new { |params| params[1].length + 1 }
  len_asm_incl = Proc.new { |params|
    raise RuntimeError.new("incl directive is not yet supported (tried to include \"#{params[0]}\"")
  }

  
  INSTRUCTIONS = {
    # :name => [op, len, params, emitter]
    # if op or len is a Proc, then it will be invoked with the instruction:s
    # parameters as the first argument.
    # emitter and op can be nil.
    # if params is nil, then it is up to the Procs (if any) used in the
    # definition to verify the amount of parameters
    
    # arithmetic instructions
    :add => [0x10, 1, 2, :art_main],
    :adc => [0x11, 1, 2, :art_main],
    :sub => [0x12, 1, 2, :art_main],
    :and => [0x13, 1, 2, :art_main],
    :lor => [0x14, 1, 2, :art_main],
    :xor => [0x15, 1, 2, :art_main],
    :not => [0x16, 1, 1,  :art_alt],
    :shr => [0x17, 1, 1,  :art_alt],

    # interrupts
    :rte => [0x21, 0, 0, :gen_none],
    :int => [0x20, 1, 1, :gen_p1_a],
    
    # stack
    :psh => [op_low_fp.curry[0x70], 0, 1, :gen_r1],
    :pop => [op_low_fp.curry[0x80], 0, 1, :gen_r1],

    # register
    :mov => [0x90, 1, 2, :gen_split1],
    :xch => [0x91, 1, 2, :gen_split1],
    :clr => [op_low_fp.curry[0x60], 0, 1, :gen_r1], 

    # direct jumps
    :rtn => [0xA6, 0, 0, :gen_none],
    :jmp => [0xA0, 2, 1, :gen_p2_a],
    :jpz => [0xA1, 2, 1, :gen_p2_a],
    :jps => [0xA2, 2, 1, :gen_p2_a],
    :jpc => [0xA3, 2, 1, :gen_p2_a],
    :jpi => [0xA4, 2, 1, :gen_p2_a],
    :jsr => [0xA5, 2, 1, :gen_p2_a],
    :jmi => [0xA8, len_p1_type, 1, :jmi],

    # indexed memory
    :ldi => [op_ldi_sti_type.curry[0xB8], len_p2_type, 2, :ldi_sti],
    :sti => [op_ldi_sti_type.curry[0xB0], len_p2_type, 2, :ldi_sti],

    # memory
    :ldm => [op_low_fp.curry[0xE0], 2, 2, :gen_p2_b],
    :stm => [op_low_fp.curry[0xF0], 2, 2, :gen_p2_b],

    # pseudo/other
    :nop => [0,    0, 0,   :gen_none],
    :shl => [0x10, 1, 1, :art_p1_dup],  # SHL Rn is an alias for ADD Rn, Rn
    :tst => [0x15, 1, 1, :art_p1_dup],  # TST Rn is an alias for XOR Rn, Rn
    :ldc => [op_low_fp.curry[0xD0], 1, 2, :gen_p1_a],

    # asm directives
    :label => [nil, 0,   1,  :asm_label],
    :orig  => [nil, 0,   1,   :asm_orig],
    :byte  => [nil, 1, nil, :data_lbl_1],
    :word  => [nil, len_asm_word, nil, :data_lbl_2],
    :incl  => [nil, len_asm_incl,   1,   :asm_incl],
    :data  => [nil, len_asm_data, nil, :data_lbl_a],
    :ascii => [nil, len_asm_asci, nil, :data_lbl_s],
    :asciz => [nil, len_asm_ascz, nil, :data_lbl_z]
  }
end
