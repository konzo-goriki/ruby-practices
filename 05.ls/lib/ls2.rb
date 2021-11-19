require 'pathname'

def run_ls(pathname, colmun_size: 3, long_format: false, reverse: false, show_dots: false)
  filenames = pathname.glob('*').map(&:basename).map(&:to_s).sort
  max_filename_count = filenames.map(&:size).max
  row_size = (filenames.count.to_f / colmun_size).ceil
  transposed_filenames = safe_transpose(filenames.each_slice(row_size).to_a)
  format_table(transposed_filenames, max_filename_count)
end

def safe_transpose(sliced_filenames)
  sliced_filenames[0].zip(*sliced_filenames[1..-1])
end

def format_table(filenames, max_filename_count)
  filenames.map do |row_files|
    row_files.map { |file| file&.ljust(max_filename_count + 1) }.join.rstrip
  end.join("\n")
end
