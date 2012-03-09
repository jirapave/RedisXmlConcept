module RedXmlApi
  module CollectionAware
    def create_child_collection(name)
      begin
        coll_id = @coll_service.create_child_collection(name)
        return Collection.new(@env_id, coll_id)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "No collection was created."
      end
    end

    def delete_child_collection(name)
      begin
        @coll_service.delete_child_collection(name)
      rescue Exception => ex
        puts "#{ex.message}"
        puts "Unknown error has occured."
      end
    end

    def delete_all_child_collections()
      begin
        @coll_service.delete_all_child_collections
      rescue Exception => ex
        puts "#{ex.message}"
        puts "Unknown error has occured."
      end
    end

    def get_child_collection(name)
      begin
        coll_id = @coll_service.get_child_collection_id(name)
        return Collection.new(@env_id, coll_id)
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Collection can't be obtained."
      end
    end

    def get_all_child_collections()
      begin
        all_ids = @env_service.get_all_child_collection_ids
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
    
    def get_id()
      @coll_service.get_collection_id
    end

    def get_all_child_collections_names()
      @coll_service.get_all_child_collections_names
    end
    
    def get_all_child_collections_ids()
      @coll_service.get_all_child_collections_ids
    end

    def rename_child_collection(old_name, name)
      begin
        @coll_service.rename_child_collection(old_name, name)
        return true
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Collection could't be renamed."
      return false
      end
    end
  end
end