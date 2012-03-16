require_relative "../transformer/collection_service"
require_relative "collection"
require_relative "environment_manager"

module RedXmlApi
  
  class Environment
    attr_reader :id
    
    include RedXmlApi::CollectionAware
    
    def initialize(env_id)
      @env_id = env_id
      @env_manager = RedXmlApi::EnvironmentManager.new
      @coll_service = Transformer::CollectionService.new(@env_id)
    end
    
    def rename!(old_name, name)
      begin
        return @env_manager.rename_environment?(old_name, name)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Collection could't be renamed."
        return false
      end
    end
  end
end