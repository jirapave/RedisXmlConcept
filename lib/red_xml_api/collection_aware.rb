module RedXmlApi
  module CollectionAware
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
      begin
        @coll_service.delete_collection(name)
      rescue Exception => ex
        puts "#{ex.message}"
        puts "Unknown error has occured."
      end
    end

    def delete_all_collections()
      begin
        @coll_service.delete_all_collections
      rescue Exception => ex
        puts "#{ex.message}"
        puts "Unknown error has occured."
      end
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

    def get_all_collections_names()
      @coll_service.get_all_collections_names
    end

    def rename_collection(old_name, name)
      begin
        @coll_service.rename_collection(old_name, name)
        return true
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Collection could't be renamed."
      return false
      end
    end
  end
end