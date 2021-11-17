#! /usr/bin/env ruby

# wc.rb

# frozen_string_literal: true

require 'optparse'

def parse_options
  options = {}
  opt = OptionParser.new

  opt.on('-l') { |v| options['-l'] = v }
  opt.on('-w') { |v| options['-w'] = v }
  opt.on('-c') { |v| options['-c'] = v }

  opt.parse!(ARGV)

  options
end

def count_lines(file)
  str = File.read(file)
  str.lines.count
end

def count_words(file)
  str = File.read(file)
  ary = str.split(/\s+/)
  ary.size
end

def count_bytes(file)
  str = File.read(file)
  str.bytesize
end

def show_stdin(options)
  str = $stdin.readlines.join
  print " #{str.lines.count.to_s.rjust(7)}" if options['-l']
  print " #{str.split(/\s+/).size.to_s.rjust(7)}" if options['-w']
  print " #{str.bytesize.to_s.rjust(7)}" if options['-c']
  print "\n"
end

def show_total_params(total_params, options)
  print " #{total_params[:lines].to_s.rjust(7)}" if options['-l']
  print " #{total_params[:words].to_s.rjust(7)}" if options['-w']
  print " #{total_params[:bytes].to_s.rjust(7)}" if options['-c']
  print ' total'
  print "\n"
end

def show_files(options)
  patterns = ARGV
  files = Dir.glob(patterns)

  total_params = { lines: 0, words: 0, bytes: 0 } if files.count >= 2

  files.each do |file|
    lines = count_lines(file)
    print " #{lines.to_s.rjust(7)}" if options['-l']
    words = count_words(file)
    print " #{words.to_s.rjust(7)}" if options['-w']
    bytes = count_bytes(file)
    print " #{bytes.to_s.rjust(7)}" if options['-c']
    print " #{file}"
    print "\n"

    next if files.count < 2

    total_params[:lines] += lines
    total_params[:words] += words
    total_params[:bytes] += bytes
  end
  show_total_params(total_params, options) if files.count >= 2
end

def wc
  options = parse_options
  options.update({ '-l' => true, '-c' => true, '-w' => true }) if options.empty?

  if File.pipe?($stdin) || !File.select([$stdin], [], [], 0).nil?
    show_stdin(options)
  else
    show_files(options)
  end
end

wc
