require_relative "../transformer/exceptions"

module RedXmlApi
  class DocumentIterator
    def initialize(doc_service)
      @doc_service = doc_service
      @doc_names = @doc_service.get_all_documents_names
      @size = @doc_names.length
      @iter = 0
    end
    
    def hasNext()
      return true if @iter < @size
      return false
    end
    
    def nextDocument()
      raise Transformer::NoIteratorNext, "There are no more documents to iterate over." if @iter >= @size
      result @doc_service.find_document(@doc_names[@iter])
      @iter += 1
      return result
    end
  end
end