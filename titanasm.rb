#!/usr/bin/env ruby

require 'optparse'

$:.unshift '.'
require 'lib/util'
require 'lib/emitters'
require 'lib/instructions'
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
  # the downsides of using a DSL for this...
  contents = f.read.gsub(/^(\s*)(and|not)(\s+)/, '\1\2_\3')
  pp_hex(Titan::Program.new(contents, options[:file]).assemble)
end
