require_relative "../base_interface/db_interface"

module RedXmlApi
  class Collection
    
    def initialize(env_name, coll_name)
      @doc_service = Transformer::DocumentService.new(env_name, coll_name)
    end
    
    def save_document(file_name)
      
    end
    
    def delete_document(file_name)
      
    end
    
    def delete_all_documents()
      
    end
    
    def get_document(file_name)
      
    end
    
    def get_all_documents()
      
    end
  end
end