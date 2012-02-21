#This class if for DEBUG purposes only, will be deleted
#PROPER TESTs will be written in project/test folder and runned by run_tests file in bin folder



require_relative "../lib/base_interface/db_interface"
require_relative "../lib/transformer/document_service"
require_relative "../lib/transformer/key_element_builder"
require_relative "../lib/xquery/xquery_controller"
require_relative "../lib/xml/node"
require_relative "../lib/xquery/helper"

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
query = "for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept<=\"ACC\" order by $prod/name return <elem>$prod/name</elem>"
# query = "doc(  \"catalog.xml\"  )/prod:catalog/product[position()<3]/@dept[@dept = \"ACC\"]"
# query = "doc(  \"catalog.xml\"  )/catalog/product[@dept = \"ACC\"]"
# query = "doc(  \"catalog.xml\"  )/catalog/*[2 < position()]/@dept"
# query = "doc(  \"catalog.xml\"  )/catalog/product/number[. = 443]"
# query = "doc(\"catalog.xml\")/catalog/product[number >= 563]/@dept"
# query = "doc(  \"catalog.xml\"  )/catalog/product"
# query = "doc(  \"catalog.xml\"  )/catalog/*/@dept"


puts "query: #{query}"

results = xquery_controller.get_results(query)
XQuery::Helper.print_results(results)




