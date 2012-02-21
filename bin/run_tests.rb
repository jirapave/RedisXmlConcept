require_relative "../lib/base_interface/db_interface"

require "rubygems"
require "nokogiri"
require "test/unit"

#ALL the TEST we want to perform
require_relative "../test/xquery/xpath_tests"

db = BaseInterface::DBInterface.instance





