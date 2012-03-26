def self.pp_hex(data)
  row = 0
  while seg = data.slice!(0, 16).unpack('C*')
    break if seg.empty?

    puts "%04x #{'%02X ' * (16 - (16 - seg.length))}" % seg.unshift(row)
    row += 16
  end
end
