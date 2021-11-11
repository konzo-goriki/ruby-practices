#! /usr/bin/env ruby

# ls.rb

# frozen_string_literal: true

# require
require 'date'
require 'etc'
require 'optparse'

# const define
COLUMN_SIZE = 3

## file type
S_IFMT = '170000'.to_i(8)
S_IFFIFO = '010000'.to_i(8)
S_IFCHR = '020000'.to_i(8)
S_IFDIR = '040000'.to_i(8)
S_IFBLK = '060000'.to_i(8)
S_IFREG = '100000'.to_i(8)
S_IFLNK = '120000'.to_i(8)
S_IFSOCK = '140000'.to_i(8)

##
S_ISVTX = '001000'.to_i(8)
S_ISGID = '002000'.to_i(8)
S_ISUID = '004000'.to_i(8)

## user
S_IRUSR = '000400'.to_i(8)
S_IWUSR = '000200'.to_i(8)
S_IXUSR = '000100'.to_i(8)
CONV_MODE_USR_HASH = {
  0 => '-',
  S_IXUSR => 'x',
  S_ISUID => 'S',
  S_IXUSR | S_ISUID => 's'
}.freeze

## group
S_IRGRP = '000040'.to_i(8)
S_IWGRP = '000020'.to_i(8)
S_IXGRP = '000010'.to_i(8)
CONV_MODE_GRP_HASH = {
  0 => '-',
  S_IXGRP => 'x',
  S_ISGID => 'S',
  S_IXGRP | S_ISGID => 's'
}.freeze
## other
S_IROTH = '000004'.to_i(8)
S_IWOTH = '000002'.to_i(8)
S_IXOTH = '000001'.to_i(8)
CONV_MODE_OTH_HASH = {
  0 => '-',
  S_IXOTH => 'x',
  S_ISVTX => 'T',
  S_IXOTH | S_ISVTX => 't'
}.freeze

def parse_options
  options = {}
  opt = OptionParser.new

  opt.on('-l') { |v| options['-l'] = v }
  opt.parse!(ARGV)

  options
end

def show_normal_format_files(files)
  max_file_len = files.max_by(&:length).length
  sliced_files = []
  files.each_slice((files.size.to_f / COLUMN_SIZE).ceil(0)) { |f| sliced_files << f }

  # Array#transposeのためにsliced_filesの要素数を揃える
  (sliced_files.first.size - sliced_files.last.size).times { sliced_files.last << nil }

  sliced_files.transpose.map do |rows|
    rows.map do |file|
      print "#{file&.ljust(max_file_len)}  "
    end
    print "\n"
  end
end

def count_blocks(files)
  sum = 0
  files.map do |file|
    sum += File.stat(file).blocks
  end
  sum
end

def convert_strmode_file_type(mode)
  symbol = []

  # file type
  case (mode & S_IFMT)
  when S_IFFIFO
    symbol << 'p'
  when S_IFCHR
    symbol << 'c'
  when S_IFDIR
    symbol << 'd'
  when S_IFBLK
    symbol << 'b'
  when S_IFREG
    symbol << '-'
  when S_IFLNK
    symbol << 'l'
  when S_IFSOCK
    symbol << 's'
  end
end

def convert_strmode_user(mode)
  symbol = []
  # user
  symbol << ((mode & S_IRUSR).zero? ? '-' : 'r')
  symbol << ((mode & S_IWUSR).zero? ? '-' : 'w')
  symbol << CONV_MODE_USR_HASH[mode & (S_IXUSR | S_ISUID)]
end

def convert_strmode_group(mode)
  symbol = []
  # group
  symbol << ((mode & S_IRGRP).zero? ? '-' : 'r')
  symbol << ((mode & S_IWGRP).zero? ? '-' : 'w')
  symbol << CONV_MODE_GRP_HASH[mode & (S_IXGRP | S_ISGID)]
end

def convert_strmode_other(mode)
  symbol = []
  # other
  symbol << ((mode & S_IROTH).zero? ? '-' : 'r')
  symbol << ((mode & S_IWOTH).zero? ? '-' : 'w')
  symbol << CONV_MODE_OTH_HASH[mode & (S_IXOTH | S_ISVTX)]
end

def convert_strmode(mode)
  symbol = convert_strmode_file_type(mode), convert_strmode_user(mode), convert_strmode_group(mode), convert_strmode_other(mode)
  symbol.join
end

def show_long_listing_format_files(files)
  # 列整形用
  max_nlink_digits = File.stat(files.max_by { |file| File.stat(file).nlink }).size.to_s.length
  max_username_length = Etc.getpwuid(File.stat(files.max_by { |file| Etc.getpwuid(File.stat(file).uid).name }).uid).name.length
  max_groupname_length = Etc.getgrgid(File.stat(files.max_by { |file| Etc.getgrgid(File.stat(file).gid).name }).gid).name.length
  max_size_digits = File.stat(files.max_by { |file| File.stat(file).size }).size.to_s.length

  puts "total #{count_blocks(files)}"

  files.each do |file|
    print "#{convert_strmode(File.stat(file).mode)} "
    print "#{File.stat(file).nlink.to_s.rjust(max_nlink_digits)} "
    print "#{Etc.getpwuid(File.stat(file).uid).name.rjust(max_username_length)}  "
    print "#{Etc.getgrgid(File.stat(file).gid).name.rjust(max_groupname_length)}  "
    print "#{File.stat(file).size.to_s.rjust(max_size_digits)} "
    time_format = if Date.today.year == File.stat(file).mtime.year
                    '%_m %_d %H:%M'
                  else
                    '%_m %_d  %Y'
                  end
    print "#{File.stat(file).mtime.strftime(time_format)} "
    print file
    print "\n"
  end
end

def ls
  options = parse_options
  files = Dir.glob('*')

  if options['-l']
    show_long_listing_format_files(files)
  else
    show_normal_format_files(files)
  end
end

ls
