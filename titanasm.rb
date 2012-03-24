#!/usr/bin/env ruby

require 'optparse'

$:.unshift '.'
require 'lib/program'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: titanasm.rb [options]'

  opts.on('-f', '--file PATH', 'Path of file to assemble') do |f|
    options[:file] = f
  end

  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
end.parse!

unless options[:file]
  puts 'No input file specified. (Try --help).'
  exit 1
end

File.open(options[:file], 'rb') do |f|
  # temporary
  Titan::Program.new(f.read, options[:file]).assemble.each_byte do |b|
    puts "%04b %04b" % [b >> 4, b & 0xF]
  end
end