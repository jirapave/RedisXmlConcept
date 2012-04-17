class XQueryTestHelper

  ENV_NAME = "env_test_xquery"
  COLL_NAME = "coll_test_xquery"
  FILE_PATH = File.absolute_path("#{__FILE__}/../catalog.xml")
  
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

  def create_test_file(file_path=FILE_PATH, overwrite=true)
    begin
      @coll.save_document(file_path)
    rescue Transformer::MappingException
      puts "document already exists in database"
      if(overwrite)
        puts "deleting and creating new one"
        cleanup_test_file(file_path)
        @coll.save_document(file_path)
      end
    end
  end

  def cleanup_test_file(file_path=FILE_PATH)
    file_name = File.basename(file_path)
    if(@coll.delete_document?(file_name))
      puts "Test document removed."
    else
      puts "Test document was NOT removed."
    end
  end

end
