require_relative "../lib/transformer/key_element_builder"
require_relative "../lib/base_interface/db_interface"
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

#Now how it should be used:
#env_manager = EnvironmentManager.new()
#env = env_manager.create_environment("test")
#coll = env.create_collection("new")
#coll.save_document(file_name)
#document = coll.get_document(file_name)
#puts document

#db_interface is Singleton, redis is class variable
db = BaseInterface::DBInterface.instance

#====DOCUMENT SAVE AND RETRIEVE
file_name = "books-5000.xml"
document_service = Transformer::DocumentService.new()
time do
#First argument is database name, second is collection
  document_service.save_document(file_name, 1, 1)
end

time do
  puts "retrieving document from database..."
  # retrieve document string, whole DOM is created, Node overrides to_s
  # puts document_service.find_file(file_name, 1, 1)
  puts document_service.find_file(file_name, 1, 1)
end
