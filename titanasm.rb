#!/usr/bin/env ruby

require 'optparse'

$:.unshift '.'
require 'lib/util'
require 'lib/emitters'
require 'lib/instructions'
require 'lib/program'

opts = {
  :type => :assemble
}

OptionParser.new do |options|
  options.banner = 'Usage: titanasm.rb [options]'

  options.on('-f', '--file PATH', 'Path of file to assemble') do |f|
    opts[:file] = f
  end

  options.on('-o', '--out PATH', 'Path to assembled output.') do |f|
    opts[:out] = f
  end

  options.on('-m', '--mode MODE', [:assemble, :asm_src],
             'Assemble mode (assemble, asm_src).') do |t|
    opts[:type] = t 
  end

  options.on('-s', '--stdout', 'Write assembled code to STDOUT') do
    opts[:stdout] = true
  end

  options.on('-H', '--hex-dump', 'Print a hexdump.') do
    opts[:hex_dump] = true
  end

  options.on_tail('-h', '--help', 'Show this message') do
    puts options
    exit
  end
end.parse!


unless opts[:file]
  puts 'No input file specified. (Try --help).'
  exit 1
end

ext = opts[:type] == :asm_src ? '.asm' : '.tit'
opts[:out] ||= File.basename(opts[:file], File.extname(opts[:file])) + ext

File.open(opts[:file], 'rb') do |f|
  # the downside of using a DSL for this...
  contents = f.read.gsub(/^(\s*)(and|not)(\s+)/, '\1\2_\3')

  output = Titan::Program.new(contents, opts[:file]).assemble(opts[:type])

  if opts[:hex_dump]
    Titan.pp_hex(output)
  elsif opts[:stdout]
    puts output
  elsif opts[:out]
    File.open(opts[:out], 'wb') do |f|
      f.write(output)
    end
  end
end
