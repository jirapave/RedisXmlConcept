require "singleton"
require "yaml"
require "redis/connection/hiredis"
require "redis"
require "rubygems"
require "nokogiri"
require "observer"
puts "xml_db_api/database_manager.rb"
Dir["#{File.dirname(__FILE__)}/transformer/*.rb"].each { |file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/red_xml_api/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/xml_db_api/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/transformer/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/base_interface/*.rb"].each {|file| require "#{file}" }
Dir["#{File.dirname(__FILE__)}/xml/*.rb"].each {|file| require "#{file}" }
