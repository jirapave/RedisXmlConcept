require_relative "xquery_test_helper"
require_relative "../../lib/redxml.rb"

file_path = "size22-4.xml"

xquery_test_helper = XQueryTestHelper.new
xquery_test_helper.create_test_file(file_path, false)

def self.time
  start = Time.now
  yield
  time = Time.now - start
  puts "Execution time: #{time} s"
end


results = []

self.time do
xquery_controller = XQuery::XQueryController.new(XQueryTestHelper::ENV_NAME, XQueryTestHelper::COLL_NAME)


#QUERIES
# results = xquery_controller.get_results('doc("size22-4.xml")//mailbox/mail[date ge "01/01/2000"]/from/text()')
results = xquery_controller.get_results('doc("size22-4.xml")/site/regions/namerica/item/mailbox/mail[date ge "01/01/2000"]/from/text()')
# results = xquery_controller.get_results('for $t in doc("size22-4.xml")//mailbox/mail[date ge "01/01/2000"]/from/text()
                                          # order by $t
                                          # return $t')
# results = xquery_controller.get_results('for $t in doc("size>1-4>coeff>0-0-1.xml")/site/regions/*/item/mailbox/mail[date ge "01/01/2000"]/from/text()
                                          # order by $t
                                          # return $t')
end

puts "result count: #{results.length}"
results.each { |result|
  puts "  #{result}"
}
