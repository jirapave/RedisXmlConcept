require 'simplecov'
SimpleCov.start
tests = []
#Dir["test/*.rb"].each {|file| tests << file }
Dir["./test_transformer/*.rb"].each {|file| tests << file }
Dir["./test_base_interface/*.rb"].each {|file| tests << file }
Dir["./test_xml_db_api/*.rb"].each {|file| tests << file }
Dir["./integration_tests/*.rb"].each {|file| tests << file }
require_relative "../lib/redxml"
tests.each do |test|
  puts "#{test}"
  require_relative "#{test}"
end
