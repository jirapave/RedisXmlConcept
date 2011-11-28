require_relative "../lib/transformer/key_element_builder"
require_relative "../lib/base_interface/db_interface"
require_relative "../lib/transformer/key_builder"
require_relative "../lib/transformer/document_service"
require_relative "../lib/xml/sax_document"
require "rubygems"
require "nokogiri"



def time
  start = Time.now
  yield
  time = Time.now - start
  puts "Execution time: #{time} s"
end

#db_interface is Singleton, redis is class variable
db = BaseInterface::DBInterface.instance

#====DOCUMENT SAVE AND RETRIEVE
file_name = "books-test5.xml"
document_service = Transformer::DocumentService.new()
time do
#First argument is database name, second is collection
  document_service.save_document(1,1,file_name)
end

time do
  puts "retrieving document from database..."
  # retrieve document string, whole DOM is created, Node overrides to_s
  puts document_service.find_file(file_name, 1, 1)
end

#parser = Nokogiri::XML::SAX::Parser.new(XML::SaxDocument.new(self))
#parser.parse(File.open(file_name, 'rb'))

#1. Run nokogiri, fix it so it works - DONE
#2. Load book.xml, choose one node and save it using XML Transformer
#3. => implement KeyBuilder, there will be changes, maybe we need more methods...change names.. DONE
#4. => implement XML Transformer, atleast save remove and find node
#5. Tro to save node from book.xml, find it a remove it
#6. Write tests!
#7. When this is done, => implementation of document_service

#keyBuilder test
#puts "KeyBuilder test"
#aaa = Transformer::KeyBuilder
# puts Transformer::KeyBuilder.attributes_key("neco")
# puts Transformer::KeyBuilder.attributes_order_key("neco")
# puts Transformer::KeyBuilder.attributes_order_key("neco<attributes")
# puts Transformer::KeyBuilder.count_key("neco")
# puts Transformer::KeyBuilder.document_info("db::coll::id1::root::movie>1::cast>1::actor>2")
# puts Transformer::KeyBuilder.document_info("db::coll::id")
# puts Transformer::KeyBuilder.element_key("db::coll::id1::root::movie>1::cast>1::actor>2", "name", 3);
# puts Transformer::KeyBuilder.next_element_key("db::coll::id1::root::movie>1::cast>1::actor>2");
# puts Transformer::KeyBuilder.parent_key("db::coll::id1::root::movie>1::cast>1::actor>2");
# puts Transformer::KeyBuilder.root_key("db::coll::id1::root::movie>1::cast>1::actor>2");
# puts Transformer::KeyBuilder.text_key("db::coll::id1::root::movie>1::cast>1::actor>2", 4);

#====DBInterface TEST====
#Add to hash using array and get result hash
#Hashes like array or like hashes? Rrrays for now
#hash = %w(field-1 value-1 field-2 value-2)
#Add to hash, overwrite all
#db.add_to_hash "hash", *hash, true
#result_hash = db.find_value "hash"
#puts result_hash.inspect

#Add to list and get result
#strs = %w(aaa bbb ccc ddd)
#db.add_to_list "list", *strs
#result_list = db.find_value("list")
#puts result_list.inspect

#Add key_string pairs
#strs = %w(key-1 string-1 key-2 string-2)
#db.save_string_entries *strs, true
#result_one = db.find_value("key-1")
#result_two = db.find_value("key-2")
#puts "result-1: #{result_one}, result-2: #{result_two}"
