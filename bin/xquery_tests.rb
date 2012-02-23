#This class if for DEBUG purposes only, will be deleted
#PROPER TESTs will be written in project/test folder and runned by run_tests file in bin folder

file_name = "../bin/catalog.xml"
puts File.file?(file_name)
exit


require_relative "../lib/base_interface/db_interface"
require_relative "../lib/transformer/document_service"
require_relative "../lib/transformer/key_element_builder"
require_relative "../lib/xquery/xquery_controller"
require_relative "../lib/xml/node"
require_relative "../lib/xquery/helper"

require "rubygems"
require "nokogiri"

@env_name = "env_test"
@coll_name = "coll_test"
file_path = "catalog.xml"
env_manager = RedXmlApi::EnvironmentManager.new()
env = env_manager.create_environment(@env_name)
if(env == nil)
  env = RedXmlApi::Environment.new(@env_name)
end
coll = env.create_collection(@coll_name)
if(coll == nil)
  coll = RedXmlApi::Collection.new(@env_name, @coll_name)
end
begin
  coll.save_document(file_path)
rescue Transformer::MappingException
  puts "ok, document exists"
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




