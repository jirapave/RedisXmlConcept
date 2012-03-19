module XQuery
  class XQueryTestHelper
    
    ENV_NAME = "env_test_xquery"
    COLL_NAME = "coll_test_xquery"
    FILE_PATH = "catalog.xml"
    
    def initialize
      env_manager = RedXmlApi::EnvironmentManager.new
      @env = env_manager.create_environment(ENV_NAME)
      if(@env == nil)
        @env = env_manager.get_environment(ENV_NAME)
      end
      @coll = @env.create_child_collection(COLL_NAME)
      if(@coll == nil)
        @coll = @env.get_child_collection(COLL_NAME)
      end
    end
    
    def create_test_file
      begin
        @coll.save_document(FILE_PATH)
      rescue Transformer::MappingException
        puts "document exists, deleting and creating new one"
        cleanup_test_file
        @coll.save_document(FILE_PATH)
      end
    end
    
    def cleanup_test_file
      file_name = File.basename(FILE_PATH)
      if(@coll.delete_document?(file_name))
        puts "Test document removed."
      else
        puts "Test document was NOT removed."
      end
    end
    
  end
end