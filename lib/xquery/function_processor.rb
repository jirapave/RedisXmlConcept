require_relative "../transformer/key_builder"
require_relative "../transformer/document_service"
require_relative "query_string_error"


module XQuery
  class FunctionProcessor
    
    def initialize(database, collection)
      @database = database
      @collection = collection
    end
    
    
    def doc(path)#:Transformer::Key
      document_service = Transformer::DocumentService.new(@database, @collection)
      file_id = document_service.document_exist?(path)
      if(file_id == nil)
        raise QueryStringError, "file #{file_name} not found in database" 
      end
      return Transformer::KeyBuilder.create(@database, @collection, path)
    end
    
  end
end

