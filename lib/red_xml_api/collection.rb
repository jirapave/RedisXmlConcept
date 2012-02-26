require_relative "../base_interface/db_interface"
require_relative "../transformer/document_service"
require_relative "../transformer/mapping_service"

module RedXmlApi
  class Collection

    def initialize(env_id, coll_id)
      @doc_service = Transformer::DocumentService.new(env_id, coll_id)
    end
    
    def save_document(file_name)
      @doc_service.save_document(file_name)
    end
    
    def delete_document?(file_name)
      begin
        @doc_service.delete_document(file_name)
        return true
      rescue Transformer::MappingException => ex
        puts "#{ex.message}"
        puts "Document #{fil_name} doesn't exist, delete operation failed."
        return false
      rescue Exception => e
        puts "#{e.message}"
        puts "Unknow error has occured, document #{file_name} was not deleted"
        return false
      end
    end
    
    def delete_all_documents()
      all_names = @doc_service.get_all_documents_names
      all_names.each do |name|
        delete_document?(name)
      end
    end
    
    def get_document(file_name)
      begin
        return @doc_service.find_document(file_name)
      rescue Transformer::MappingException => ex
        puts "#{ex.message}"
        puts "Document couldn't be obtained."
      end
    end
    
    #Caution here, could take long time to load when using many large files (minutes), reccommendation is
    #to use DocumentIterator
    def get_all_documents()
      begin
        all_names = @doc_service.get_all_documents_names
        result = []
        all_names.each do |name|
          result << @doc_service.find_document(name)
        end
        return result
      rescue Exception => ex
        puts "Unknown error occured, please try again." 
        puts ex.message
      end
    end
    
    def get_document_iterator()
      return RedXmlApi::DocumentIterator.new(@doc_service)
    end
    
    def get_all_documents_names()
      @doc_service.get_all_documents_names
    end
    
    def rename_document(old_name, name)
      begin
        @doc_service.rename_document(old_name, name)
        return true
      rescue Transformer::MappingException => ex
        puts ex.message
        puts "Collection could't be renamed."
        return false
      end
    end
    
    def rename!(old_name, name)
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