require_relative "../base_interface/db_interface"
require_relative "../transformer/mapping_service"

module RedXmlApi
  class Collection
    
    def initialize(env_name, coll_name)
      env_id = Transformer::MappingService.map_env(env_name)
      coll_id = Transformer::MappingService.map_coll(env_id, coll_name)
      @doc_service = Transformer::DocumentService.new(env_id, coll_id)
      #TODO check - document service was called with env_name, coll_name and it didn't work
    end
    
    def save_document(file_name)
      @doc_service.save_document(file_name)
    end
    
    def delete_document(file_name)
      
    end
    
    def delete_all_documents()
      
    end
    
    def get_document(file_name)
      @doc_service.find_document(file_name)
    end
    
    def get_all_documents()
      
    end
  end
end