# frozen_string_literal: true

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

def run_ls(pathname, long_format: false, reverse: false, dot_match: false)
  pattern = pathname.join('*')
  params = dot_match ? [pattern, File::FNM_DOTMATCH] : [pattern]
  file_paths = Dir.glob(*params).sort
  file_paths.reverse! if reverse
  long_format ? ls_long(file_paths) : ls_normal(file_paths)
end

def ls_normal(file_paths)
  max_file_path_count = file_paths.map { |file_path| File.basename(file_path).size }.max
  row_size = (file_paths.count.to_f / COLMUN_SIZE).ceil
  transposed_file_paths = safe_transpose(file_paths.each_slice(row_size).to_a)
  format_table(transposed_file_paths, max_file_path_count)
end

def build_data(file_path, stat)
  {
    type_and_mode: format_type_and_mode(file_path),
    nlink: stat.nlink.to_s,
    user: Etc.getpwuid(stat.uid).name,
    group: Etc.getgrgid(stat.gid).name,
    size: stat.size.to_s,
    mtime: format_mtime(file_path),
    basename: File.basename(file_path),
    blocks: stat.blocks
  }
end

def ls_long(file_paths)
  row_data = file_paths.map do |file_path|
    stat = File.stat(file_path)
    build_data(file_path, stat)
  end
  block_total = row_data.sum { |data| data[:blocks] }
  total = "total #{block_total}"
  body = render_long_format_body(row_data)
  [total, *body].join("\n")
end

def render_long_format_body(row_data)
  max_nlink = find_max_size(row_data, :nlink)
  max_user_length = find_max_size(row_data, :user)
  max_group_length = find_max_size(row_data, :group)
  max_size = find_max_size(row_data, :size)
  row_data.map do |data|
    format_row(data, max_nlink, max_user_length, max_group_length, max_size)
  end
end

def find_max_size(row_data, key)
  row_data.map { |data| data[key].size }.max
end

def format_type_and_mode(file_path)
  pathname = Pathname(file_path)
  stat = pathname.stat
  convert_strmode(stat.mode)
end

def format_mtime(file_path)
  pathname = Pathname(file_path)
  stat = pathname.stat
  time_format = (Date.today.year == stat.mtime.year ? '%_m %_d %H:%M' : '%_m %_d  %Y')
  stat.mtime.strftime(time_format)
end

def format_row(data, max_nlink, max_user_length, max_group_length, max_size)
  [
    data[:type_and_mode],
    "  #{data[:nlink].rjust(max_nlink)}",
    " #{data[:user].rjust(max_user_length)}",
    "  #{data[:group].rjust(max_group_length)}",
    "  #{data[:size].rjust(max_size)}",
    " #{data[:mtime]}",
    " #{data[:basename]}"
  ].join
end

def safe_transpose(sliced_file_paths)
  sliced_file_paths[0].zip(*sliced_file_paths[1..-1])
end

def format_table(file_paths, max_file_path_count)
  file_paths.map do |row_files|
    row_files.map do |file_path|
      basename = file_path ? File.basename(file_path) : ''
      basename.to_s.ljust(max_file_path_count + 1)
    end.join.rstrip
  end.join("\n")
end
