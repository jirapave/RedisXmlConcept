require_relative "../lib/transformer/key_element_builder"
require_relative "../lib/base_interface/db_interface"
require_relative "../lib/transformer/document_service"
require_relative "../lib/transformer/mapping_service"
require_relative "../lib/xml/sax_document"
require "rubygems"
require "nokogiri"

#require all *.rb files in certain directory
Dir["../lib/red_xml_api/*.rb"].each {|file| require file }

def time
  start = Time.now
  yield
  time = Time.now - start
  puts "Execution time: #{time} s"
end

db = BaseInterface::DBInterface.instance
#Delete whole content of database
keys = db.find_keys("*")
db.delete_keys keys unless keys.empty?

env_name = "test"
coll_name = "new"
file_path = "./books-100000.xml"
file_name = File.basename(file_path)
env_manager = RedXmlApi::EnvironmentManager.new()
env = env_manager.create_environment(env_name)
coll = env.create_collection(coll_name)
aaa = coll.create_collection("aaa")
bbb = coll.create_collection("bbb")
ccc = aaa.create_collection("ccc")
puts "new=#{coll.get_id},aaa=#{aaa.get_id}, bbb=#{bbb.get_id}, ccc=#{ccc.get_id}"
puts "PRED: aaa ma: #{aaa.get_all_collections_names}"
coll.delete_collection("aaa")
puts "PRED: aaa ma: #{aaa.get_all_collections_names}"

#debug purposes
env_id = Transformer::MappingService.map_env(env_name)
puts "env id: #{env_id}"
coll_id = Transformer::MappingService.map_coll(env_id, coll_name)
puts "coll id: #{coll_id}"

time do
  puts "Saving document..."
  coll.save_document(file_path)
end

time do
  puts "Retrieving document from database..."
  # retrieve document string, whole DOM is created, Node overrides to_s
  # puts document_service.find_file(file_name, 1, 1)
  document = coll.get_document(file_name)
  #puts document
end

#result = coll.delete_document?(file_name)
#puts "SOUBOR SMAZAN? #{result}"
#document = coll.get_document(file_name)
#puts "Document po smazani: #{document}"
#env.delete_all_collections
#puts "Mela by jit vyrvorit kolekce:"
#env.create_collection("new")
#coll = env.get_collection("new")
#coll.save_document(file_path)
#document = coll.get_document(file_name)
#puts document

