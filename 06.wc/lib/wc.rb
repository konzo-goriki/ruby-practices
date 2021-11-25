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

def count_params(file, options)
  str = File.read(file)
  params = {}
  params[:lines] = str.lines.count if options['-l']
  params[:words] = str.split(/\s+/).size if options['-w']
  params[:bytes] = str.bytesize if options['-c']
  params
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
  print " total\n"
end

def show_files(options)
  files = Dir.glob(ARGV)

  total_params = { lines: 0, words: 0, bytes: 0 }

  files.each do |file|
    params = count_params(file, options)
    if options['-l']
      print " #{params[:lines].to_s.rjust(7)}"
      total_params[:lines] += params[:lines]
    end
    if options['-w']
      print " #{params[:words].to_s.rjust(7)}"
      total_params[:words] += params[:words]
    end
    if options['-c']
      print " #{params[:bytes].to_s.rjust(7)}"
      total_params[:bytes] += params[:bytes]
    end
    print " #{file}\n"
  end
  show_total_params(total_params, options) if files.count >= 2
end

def wc
  options = parse_options
  options.update({ '-l' => true, '-c' => true, '-w' => true }) if options.empty?

  if ARGV[0]
    show_files(options)
  else
    show_stdin(options)
  end
end

wc
