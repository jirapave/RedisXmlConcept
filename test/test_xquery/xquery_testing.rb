require_relative "xquery_test_helper"
require_relative "../../lib/redxml.rb"

def self.time
  start = Time.now
  yield
  time = Time.now - start
  puts "Execution time: #{time} s"
end


#PATH TO TEST FILE
file_path = "size22-4.xml"


puts "inserting test document #{file_path}"
xquery_test_helper = XQueryTestHelper.new
xquery_test_helper.create_test_file(file_path, false)


#initialization
xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)
results = []

self.time do


#QUERIES
# results = xquery_controller.get_results('doc("size22-4.xml")//mailbox/mail[date ge "01/01/2000"]/from/text()')
results = xquery_controller.get_results('doc("size22-4.xml")/site/regions/namerica/item/mailbox/mail[date ge "01/01/2000"]/from/text()')
# results = xquery_controller.get_results('for $t in doc("size22-4.xml")//mailbox/mail[date ge "01/01/2000"]/from/text()
                                          # order by $t
                                          # return $t')
end

#DELETE TEST FILE
# xquery_test_helper.cleanup_test_file(file_path)

puts "result count: #{results.length}"
results.each { |result|
  puts "  #{result}"
}
