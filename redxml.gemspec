$:.unshift File.expand_path("../lib", __FILE__)

require "redxml/version"

Gem::Specification.new do |s|
  s.name        = 'redxml'
  s.version     = RedXML::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary     = "RedXML is an abtraction layer over Redis database to enable native XML database behaviour."
  s.description = <<-EOS
  RedXml library is a project focusing on creating a basis for new XML native database. 
  It is based on Redis key-value database as it’s underlying storage. RedXML uses own mapping of XML 
  files into Redis and creates new abstraction layer to easily work with those documents. Currently 
  XML:DB API is supported along with proprietary API to work with environments, collections and documents. 
  XPath/XQuery languages are beying implemented as a main way to query stored XML files.
  EOS
  s.authors     = ["Pavel Strnad", "Pavel Jíra", "Martin Kostolný"]
  s.email       = ['pavel.strnad@fel.cvut.cz','jirapave@fit.cvut.cz','kostomar@fit.cvut.cz']
  s.files       = ["lib/redxml.rb"]
  s.homepage    = 'https://github.com/jirapave/RedisXmlConcept'
  s.has_rdoc = true
  spec.add_dependency('nokogiri', '>= 1.5.2')
  spec.add_dependency('redis', '>= 2.2.2')
end