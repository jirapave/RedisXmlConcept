require_relative "xml_transformer"
require_relative "../xml/document"
require "nokogiri"

module Transformer
  class DocumentService
    def initialize()
      @xml_transformer = Transformer::XMLTransformer.new
    end
    
    #Database and collection are prefixes, when no one is specified, we are searching for all
    #documents in all databases in each collection
    def all_documents(database=-1,collection=-1)
      
    end
    
    def find_document(document)
      
    end
    
    def find_file(file_name, database=-1, collection=-1)
      
    end
      
    def remove_document(document)
      
    end
    
    def remove_file(file_name, database=-1, collection=-1)
      
    end
    
    def rename_document(document, name)
      
    end
    
    def rename_file(file_name, database=-1. collection=-1)
      
    end
    
    def update_document(file_name, document)
      
    end
  end
end