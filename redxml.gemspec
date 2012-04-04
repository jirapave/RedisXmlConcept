$:.unshift File.expand_path("../lib", __FILE__)

require "redxml/version"

Gem::Specification.new do |s|
  s.name        = 'redxml'
  s.version     = RedXML::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "RedXML is an abtraction layer over Redis database to enable native XML database behaviour."
  s.description = <<-EOS
  RedXml library is a project focusing on creating a basis for new XML native database. 
  It is based on Redis key-value database as it’s underlying storage. RedXML uses own mapping of XML 
  files into Redis and creates new abstraction layer to easily work with those documents. Currently 
  XML:DB API is supported with some proprietary methods to work with databases, collections and documents. 
  XPath/XQuery languages are beying implemented as a main way to query stored XML files.
  EOS
  s.authors     = ["Pavel Strnad", "Pavel Jíra", "Martin Kostolný"]
  s.email       = ['pavel.strnad@fel.cvut.cz','jirapave@fit.cvut.cz','kostomar@fit.cvut.cz']
  s.files       = Dir["{lib}/**/*.*","{examples}/**/*.*","README.rdoc"]
  s.homepage    = 'https://github.com/jirapave/RedisXmlConcept'
  s.has_rdoc = true
  s.add_dependency('nokogiri', '>= 1.5.2')
  s.add_dependency('redis', '>= 2.2.2')
  s.add_dependency('hiredis', '>= 0.4.5')
end