require_relative "../lib/base_interface/db_interface"
require_relative "../lib/transformer/document_service"
require_relative "../lib/transformer/key_element_builder"
require_relative "../lib/xquery/xquery_controller"
require_relative "../lib/xml/sax_document"
require "rubygems"
require "nokogiri"


database = 1
collection = 1
file_name = "catalog.xml"

#db_interface is Singleton, redis is class variable
db = BaseInterface::DBInterface.instance

document_service = Transformer::DocumentService.new()
if(!document_service.save_document(file_name, database, collection))
  puts "Document #{file_name} already exists in database #{database} and collection #{collection}"
end


xquery_controller = XQuery::XQueryController.new(database, collection)

query = "for $prod in doc(  \"catalog.xml\"  )/prod:catalog/product[position()<3]/@dept[1]  where $prod/@dept<=\"ACC\" order by $prod/name return $prod/name"
query = "doc(  \"catalog.xml\"  )/prod:catalog/product[position()<3]/@dept[@dept = \"ACC\"]"
query = "doc(  \"catalog.xml\"  )/catalog/product[position()<3]/@dept"
query = "doc(  \"catalog.xml\"  )/catalog/product"
query = "doc(  \"catalog.xml\"  )/catalog/*/@dept"

puts "query: #{query}"

results = xquery_controller.get_results(query)
puts "whole result (#{results.length})"
results.each { |result|
  puts result
  puts "---"
}




