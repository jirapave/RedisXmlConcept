require_relative "../lib/base_interface/db_interface"
require_relative "../test/xquery/xpath_tests"

require "rubygems"
require "nokogiri"

db = BaseInterface::DBInterface.instance

XQuery::XPathTests.test
