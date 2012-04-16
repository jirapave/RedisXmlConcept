require 'rake/testtask'
require 'rdoc/task'

$:.unshift File.expand_path("../lib", __FILE__)

require "redxml/version"

# Basic info about rakefile http://docs.rubyrake.org/user_guide/chapter03.html
# Bassically it's something like Ant

#Prepare all tests
tests = []
Dir["test/test_transformer/*.rb"].each {|file| tests << file }
Dir["test/test_base_interface/*.rb"].each {|file| tests << file }
Dir["test/test_xml_db_api/*.rb"].each {|file| tests << file }
Dir["test/integration_tests/*.rb"].each {|file| tests << file }
Dir["test/test_xquery/*_xpath.rb"].each {|file| tests << file }

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = tests
  t.verbose = false
end

desc "Run tests"
task :default => :test

RDoc::Task.new do |rd|
    rd.main = "README.rdoc"
    rd.title = "RedXML"
    rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    rd.rdoc_files.exclude("test", "bin", "examples")
    rd.options = ['--main', 'README.rdoc']
end

# Creates gem file
task :build do
  system "gem build redxml.gemspec"
end

task :install do
  system "gem install redxml-#{RedXML::VERSION}"
end

task :uninstall do
  system "gem uninstall redxml"
end
 
task :release => :build do
  system "gem push redxml-#{RedXML::VERSION}"
end