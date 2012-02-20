require_relative "../transformer/collection_service"
require_relative "collection"

module RedXmlApi
  class Environment
    attr_reader :name
    
    def initialize(env_name)
      @name = env_name
      @env_service = Transformer::EnvironmentService.new
      @coll_service = Transformer::CollectionService.new(@name)
    end
    
    def create_collection(name)
      begin
        @coll_service.create_collection(name)
        return Collection.new(@name, name)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "No environment was created."
      end
    end
    
    def delete_collection(name)
      
    end
    
    def delete_all_collections()
      
    end
    
    def get_collection()
      
    end
    
    def get_all_collections()
      
    end
    
    def rename_environment(old_name, name)
      
    end
    
    def rename_environment!(old_name, name)
      
    end
  end
end