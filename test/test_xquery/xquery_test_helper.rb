module XQuery
  class XQueryTestHelper
    
    ENV_NAME = "env_test"
    COLL_NAME = "coll_test"
    FILE_PATH = "../../bin/catalog.xml"
    
    def self.create_test_file
      env_manager = RedXmlApi::EnvironmentManager.new()
      env = env_manager.create_environment(ENV_NAME)
      if(env == nil)
        env = RedXmlApi::Environment.new(ENV_NAME)
      end
      coll = env.create_collection(COLL_NAME)
      if(coll == nil)
        coll = RedXmlApi::Collection.new(ENV_NAME, COLL_NAME)
      end
      begin
        coll.save_document(FILE_PATH)
      rescue Transformer::MappingException
        puts "ok, document exists"
      end
    end
    
    def self.cleanup_test_file
      file_name = File.basename(FILE_PATH)
      coll = RedXmlApi::Collection.new(ENV_NAME, COLL_NAME)
      if(coll.delete_document?(file_name))
        puts "Test document removed."
      end
    end
    
  end
end