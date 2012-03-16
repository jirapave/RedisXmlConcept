require 'rake/testtask'

# Basic info about rakefile http://docs.rubyrake.org/user_guide/chapter03.html
# Bassically it's something like Ant

#Prepare all tests
tests = []
Dir["test/test_transformer/*.rb"].each {|file| tests << file }
Dir["test/test_base_interface/*.rb"].each {|file| tests << file }
Dir["test/test_xml_db_api/*.rb"].each {|file| tests << file }
Dir["test/integration_tests/*.rb"].each {|file| tests << file }
#Dir["test/test_xquery/*.rb"].each {|file| tests << file }

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = tests
  t.verbose = false
end

desc "Run tests"
task :default => :test