NAIVE = 1
SHORTKEYS = 2
CUTTING = 3
HASH = 4
OLDHASH = 5 # not needed anymore, bug in HASH found, retrive time fixed

type = CUTTING

case type
  when NAIVE
    require_relative "../Naive/lib/transformer/key_element_builder"
    require_relative "../Naive/lib/base_interface/db_interface"
    require_relative "../Naive/lib/transformer/key_builder"
    require_relative "../Naive/lib/transformer/document_service"
    require_relative "../Naive/lib/xml/sax_document"
    db_name = "dbName"
    coll_name = "collName"
  when SHORTKEYS
    require_relative "../ShortKeys/lib/transformer/key_element_builder"
    require_relative "../ShortKeys/lib/base_interface/db_interface"
    require_relative "../ShortKeys/lib/transformer/key_builder"
    require_relative "../ShortKeys/lib/transformer/document_service"
    require_relative "../ShortKeys/lib/xml/sax_document"
    db_name = "1"
    coll_name = "1"
  when CUTTING
    require_relative "../Cutting/lib/transformer/key_element_builder"
    require_relative "../Cutting/lib/base_interface/db_interface"
    require_relative "../Cutting/lib/transformer/key_builder"
    require_relative "../Cutting/lib/transformer/document_service"
    require_relative "../Cutting/lib/xml/sax_document"
    db_name = "1"
    coll_name = "1"
  when HASH
    require_relative "../Hash/lib/transformer/key_element_builder"
    require_relative "../Hash/lib/base_interface/db_interface"
    require_relative "../Hash/lib/transformer/key_builder"
    require_relative "../Hash/lib/transformer/document_service"
    require_relative "../Hash/lib/xml/sax_document"
    db_name = "1"
    coll_name = "1"
  when OLDHASH
    require_relative "../OldHash/lib/transformer/key_element_builder"
    require_relative "../OldHash/lib/base_interface/db_interface"
    require_relative "../OldHash/lib/transformer/key"
    require_relative "../OldHash/lib/transformer/document_service"
    require_relative "../OldHash/lib/xml/sax_document"
    db_name = "1"
    coll_name = "1"
end


require "rubygems"
require "nokogiri"

def time
  start = Time.now
  yield
  time = Time.now - start
  puts "Execution time: #{time} s"
end


#===================================================
db = BaseInterface::DBInterface.instance

#Delete all contents of the database, so don't have to stop db, delete dump and start again
keys = db.find_keys("*")
db.delete_keys keys unless keys.empty?

#====DOCUMENT SAVE AND RETRIEVE
file_name = "books2.xml"
#file_name = "size>29-3>coeff>0-2.xml"
document_service = Transformer::DocumentService.new() if type != CUTTING
#Configuring document_service when Cutting is used, second argument = numer of last characters cut to be used as a field, has
#to be > 2, first argument = switch to use cutting by len or intelligent cutting based on elements when false
document_service = Transformer::DocumentService.new(false, 4) if type == CUTTING

time do
#First argument is database name, second is collection
  document_service.save_document(db_name,coll_name,file_name)
end

time do
  puts "retrieving document from database..."
  # retrieve document string, whole DOM is created, Node overrides to_s
  puts document_service.find_file(file_name, db_name, coll_name)
  #document_service.find_file(file_name, 1, 1)
end
