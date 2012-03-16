require "singleton"
require "yaml"
require "redis/connection/hiredis"
require "redis"
require "rubygems"
require "nokogiri"
require "observer"
puts "xml_db_api/database_manager.rb"
Dir["#{File.dirname(__FILE__)}/redxml/transformer/*.rb"].each { |file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/redxml/red_xml_api/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/redxml/xml_db_api/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/redxml/transformer/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/redxml/base_interface/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/redxml/xml/*.rb"].each {|file| require "#{file}" }
