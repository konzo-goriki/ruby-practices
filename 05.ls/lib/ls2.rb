require 'pathname'
require 'etc'
require 'date'

COLMUN_SIZE = 3

## file type
S_IFMT = '170000'.to_i(8)
S_IFFIFO = '010000'.to_i(8)
S_IFCHR = '020000'.to_i(8)
S_IFDIR = '040000'.to_i(8)
S_IFBLK = '060000'.to_i(8)
S_IFREG = '100000'.to_i(8)
S_IFLNK = '120000'.to_i(8)
S_IFSOCK = '140000'.to_i(8)
MODE_FILE_TYPE_TABLE = {
  S_IFFIFO => 'p',
  S_IFCHR => 'c',
  S_IFDIR => 'd',
  S_IFBLK => 'b',
  S_IFREG => '-',
  S_IFLNK => 'l',
  S_IFSOCK => 's'
}.freeze

##
S_ISVTX = '001000'.to_i(8)
S_ISGID = '002000'.to_i(8)
S_ISUID = '004000'.to_i(8)

## user
S_IRUSR = '000400'.to_i(8)
S_IWUSR = '000200'.to_i(8)
S_IXUSR = '000100'.to_i(8)
MODE_USR_TABLE = {
  0 => '-',
  S_IXUSR => 'x',
  S_ISUID => 'S',
  S_IXUSR | S_ISUID => 's'
}.freeze

## group
S_IRGRP = '000040'.to_i(8)
S_IWGRP = '000020'.to_i(8)
S_IXGRP = '000010'.to_i(8)
MODE_GRP_TABLE = {
  0 => '-',
  S_IXGRP => 'x',
  S_ISGID => 'S',
  S_IXGRP | S_ISGID => 's'
}.freeze
## other
S_IROTH = '000004'.to_i(8)
S_IWOTH = '000002'.to_i(8)
S_IXOTH = '000001'.to_i(8)
MODE_OTH_TABLE = {
  0 => '-',
  S_IXOTH => 'x',
  S_ISVTX => 'T',
  S_IXOTH | S_ISVTX => 't'
}.freeze

def convert_strmode_file_type(mode)
  symbol = []
  # file type
  symbol << MODE_FILE_TYPE_TABLE[mode & S_IFMT]
end

def convert_strmode_user(mode)
  symbol = []
  # user
  symbol << ((mode & S_IRUSR).zero? ? '-' : 'r')
  symbol << ((mode & S_IWUSR).zero? ? '-' : 'w')
  symbol << MODE_USR_TABLE[mode & (S_IXUSR | S_ISUID)]
end

def convert_strmode_group(mode)
  symbol = []
  # group
  symbol << ((mode & S_IRGRP).zero? ? '-' : 'r')
  symbol << ((mode & S_IWGRP).zero? ? '-' : 'w')
  symbol << MODE_GRP_TABLE[mode & (S_IXGRP | S_ISGID)]
end

def convert_strmode_other(mode)
  symbol = []
  # other
  symbol << ((mode & S_IROTH).zero? ? '-' : 'r')
  symbol << ((mode & S_IWOTH).zero? ? '-' : 'w')
  symbol << MODE_OTH_TABLE[mode & (S_IXOTH | S_ISVTX)]
end

def convert_strmode(mode)
  symbol = convert_strmode_file_type(mode), convert_strmode_user(mode), convert_strmode_group(mode), convert_strmode_other(mode)
  symbol.join
end

def run_ls(pathname, long_format: false, reverse: false, show_dots: false)
  pattern = pathname.join('*')
  params = show_dots ? [pattern, File::FNM_DOTMATCH] : [pattern]
  filenames = Dir.glob(*params).sort
  filenames.reverse! if reverse
  long_format ? ls_long(filenames) : ls_normal(filenames)
end

def ls_normal(filenames)
  max_filename_count = filenames.map { |filename| File.basename(filename).size }.max
  row_size = (filenames.count.to_f / COLMUN_SIZE).ceil
  transposed_filenames = safe_transpose(filenames.each_slice(row_size).to_a)
  format_table(transposed_filenames, max_filename_count)
end

def ls_long(filenames)
  block_total = 0
  max_nlink = 0
  max_username_length = 0
  max_groupname_length = 0
  max_size = 0
  filenames.each do |filename|
    stat = File.stat(filename)
    max_nlink = [max_nlink, stat.nlink.to_s.length].max
    max_username_length = [max_username_length, Etc.getpwuid(stat.uid).name.length].max
    max_groupname_length = [max_groupname_length, Etc.getgrgid(stat.gid).name.length].max
    max_size = [max_size, stat.size.to_s.length].max
    block_total += stat.blocks
  end
  rows = ["total #{block_total}"]
  rows += filenames.map do |filename|
    format_row(filename, max_nlink, max_username_length, max_groupname_length, max_size)
  end.join("\n")
end

def format_row(filename, max_nlink, max_username_length, max_groupname_length, max_size)
  ret = ''
  pathname = Pathname(filename)
  stat = pathname.stat
  ret += convert_strmode(stat.mode)
  ret += "  #{stat.nlink.to_s.rjust(max_nlink)}"
  ret += " #{Etc.getpwuid(stat.uid).name.rjust(max_username_length)}"
  ret += "  #{Etc.getgrgid(stat.gid).name.rjust(max_groupname_length)}"
  ret += "  #{stat.size.to_s.rjust(max_size)}"
  time_format = (Date.today.year == stat.mtime.year ? '%_m %_d %H:%M' : '%_m %_d  %Y')
  ret += " #{stat.mtime.strftime(time_format)}"
  ret += " #{pathname}"
  ret
end

def safe_transpose(sliced_filenames)
  sliced_filenames[0].zip(*sliced_filenames[1..-1])
end

def format_table(filenames, max_filename_count)
  filenames.map do |row_files|
    row_files.map do |filename|
      basename = filename ? File.basename(filename) : ''
      basename.to_s.ljust(max_filename_count + 1) 
    end.join.rstrip
  end.join("\n")
end


