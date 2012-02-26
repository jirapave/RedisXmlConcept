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

env_name = "test"
coll_name = "new"
file_path = "./books-20000.xml"
file_name = File.basename(file_path)
env_manager = RedXmlApi::EnvironmentManager.new()
env = env_manager.create_environment(env_name)
coll = env.create_collection(coll_name)

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
end
