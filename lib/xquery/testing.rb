require_relative "expression"


array = []
array << "one"
array << "two"
array << "thr"

array.each_with_index { |obj, index|
  puts "obj: #{obj}, index: #{index}"
}

