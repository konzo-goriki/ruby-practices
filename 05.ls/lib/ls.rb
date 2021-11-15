#! /usr/bin/env ruby

# ls.rb

# frozen_string_literal: true

require 'optparse'
COLUMN_SIZE = 3

def option
  options = {}
  opt = OptionParser.new

  opt.on('-a') { |v| options['-a'] = v }
  opt.parse!(ARGV)

  options
end

def show_files(files, len)
  files.transpose.map do |rows|
    rows.map do |file|
      print "#{file&.ljust(len)}  "
    end
    print "\n"
  end
end

def ls
  options = option
  files = if options['-a']
            Dir.glob('*', File::FNM_DOTMATCH)
          else
            Dir.glob('*')
          end
  max_file_len = files.max_by(&:length).length

  sliced_files = []
  files.each_slice((files.size.to_f / COLUMN_SIZE).ceil(0)) { |f| sliced_files << f }

  # Array#transposeのためにsliced_filesの要素数を揃える
  (sliced_files.first.size - sliced_files.last.size).times { sliced_files.last << nil }

  show_files(sliced_files, max_file_len)
end

ls
