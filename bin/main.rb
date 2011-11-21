require_relative "../lib/base_interface/db_interface"
#Nokogiri doesn't work for now, i have installes the gem correctly "gem install nokogiri" but still
#require "nokogiri"

#db_interface is Singleton, redis is class variable
db = BaseInterface::DBInterface.instance

#====DBInterface TEST====
#Add to hash using array and get result hash
#Hashes like array or like hashes? Rrrays for now
hash = %w(field-1 value-1 field-2 value-2)
#Add to hash, overwrite all
db.add_to_hash "hash", *hash, true
result_hash = db.find_value "hash"
puts result_hash.inspect

#Add to list and get result
strs = %w(aaa bbb ccc ddd)
db.add_to_list "list", *strs
result_list = db.find_value("list")
puts result_list.inspect

#Add key_string pairs
strs = %w(key-1 string-1 key-2 string-2)
db.save_string_entries *strs, true
result_one = db.find_value("key-1")
result_two = db.find_value("key-2")
puts "result-1: #{result_one}, result-2: #{result_two}"

#====NOKOGIRI TEST - doesnt work for now, require don' work====
#f = File.open("books.xml")
#doc = Nokogiri::XML(f)

#1. Run nokogiri, fix it so it works
#2. Load book.xml, choose one node and save it using XML Transformer
#3. => implement KeyBuilder, there will be changes, maybe we need more methods...change names..
#4. => implement XML Transformer, atleast save remove and find node
#5. Tro to save node from book.xml, find it a remove it
#6. Write tests!
#7. When this is done, => implementation of document_service
