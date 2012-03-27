module Titan
  def self.pp_hex(data)
    row = 0
    while seg = data.slice!(0, 16).unpack('C*')
      break if seg.empty?

      puts "%04X #{'%02X ' * (16 - (16 - seg.length))}" % seg.unshift(row)
      row += 16
    end
  end

  def self.produces_label?(name, args)
    return true if name == :label

    if [:byte, :word, :data, :ascii, :asciz].include?(name)
      return args.length > 1 && args[0].is_a?(Symbol) 
    end

    false
  end
end
