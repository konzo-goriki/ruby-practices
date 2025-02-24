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

def print_top_of_calendar(month, year)
  puts "#{month}月 #{year}".center(20) #20:全角(2)*7 + 半角(1)*(7-1)
  print ["日","月","火","水","木","金","土"].join(' ')
  print("\n")
end

def print_body_of_calendar(month, year)
  first_day = Date.new(year, month, 1)
  last_day = Date.new(year, month, -1)

  print "　 " * first_day.wday
  (first_day..last_day).each do |day|
    if day == Date.today
      print(day.strftime("\e[7m%e\e[0m "))
    else
      print(day.strftime("%e "))
    end
    print("\n") if day.saturday?
  end
  print("\n")
end

options = option
month = options["-m"]&.to_i || Date.today.month
year = options["-y"]&.to_i || Date.today.year
print_top_of_calendar(month, year)
print_body_of_calendar(month, year)

