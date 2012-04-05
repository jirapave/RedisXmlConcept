require_relative "../lib/redxml"

def self.time #Must be static, otherwise could rise an error, when using Nokogiri::XML::Builder with send command
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
#file_path = "./catalog.xml"
file_path = "./size>1-4>coeff>0-0-1.xml"
file_name = File.basename(file_path)
env_manager = RedXmlApi::EnvironmentManager.new()
env = env_manager.create_environment(env_name)
coll = env.create_child_collection(coll_name)

self.time do
  puts "Saving document..."
  coll.save_document(file_path)
end

self.time do
  puts "Retrieving document from database..."
  # retrieve document string, whole DOM is created, Node overrides to_s
  # puts document_service.find_file(file_name, 1, 1)
  document = coll.get_document(file_name)
  #puts document
end

