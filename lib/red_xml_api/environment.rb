require_relative "../transformer/collection_service"
require_relative "collection"

module RedXmlApi
  class Environment
    attr_reader :id
    
    def initialize(env_id)
      @env_id = env_id
      @env_manager = RedXmlApi::EnvironmentManager.new
      @coll_service = Transformer::CollectionService.new(@env_id)
    end
    
    def create_collection(name)
      begin
        coll_id = @coll_service.create_collection(name)
        return Collection.new(@env_id, coll_id)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "No collection was created."
      end
    end
    
    def delete_collection(name)
      
    end
    
    def delete_all_collections()
      
    end
    
    def get_collection(name)
      begin
        coll_id = @coll_service.get_collection_id(name)
        return Collection.new(@env_id, coll_id)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Collection can't be obtained."
      end
    end
    
    def get_all_collections()
      begin
        all_ids = @env_service.get_all_collection_ids
        result = []
        all_ids.each do |id|
          result << Collection.new(@env_id, id)
        end
        return result
      rescue Exception => ex
        puts "Unknown error occured, please try again." 
        puts ex.message
      end
    end
    
    def rename!(old_name, name)
      @env_manager.rename_environment?(old_name, name)
    end
  end
end