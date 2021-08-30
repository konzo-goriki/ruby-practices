#! /usr/bin/env ruby
# calendar.rb
require "date"
require "optparse"

def option
  options = {}
  opt = OptionParser.new

  opt.on("-m VAL") {|v| options["-m"] = v }
  opt.on("-y VAL ") {|v| options["-y"] = v }
  opt.parse!(ARGV)

  options
end

def print_top_of_calendar(month=nil,year=nil)
  month ||= Date.today.month
  year ||= Date.today.year

  puts("      #{month}月 #{year}")
  ["日","月","火","水","木","金","土"].each {|w| print("#{w} ") }
  print("\n")
end

def print_body_of_calendar(month=nil,year=nil)
  month ||= Date.today.month
  year ||= Date.today.year

  first_day = Date.new(year,month,1)
  last_day = Date.new(year,month,-1)

  first_day.wday.times {print("　 ")}
  (first_day..last_day).each do |day|
    unless day == Date.today then
      print("#{day.strftime("%e ")}")
    else
      print("#{day.strftime("\e[7m%e\e[0m ")}")
    end
    print("\n") if day.saturday?
  end
  print("\n")
end

def to_i(str)
  str.to_i unless str.nil?
end

options = option
month = to_i(options["-m"])
year = to_i(options["-y"])
print_top_of_calendar(month, year)
print_body_of_calendar(month, year)

