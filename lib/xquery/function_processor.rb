require_relative "../transformer/key_element_builder"
require_relative "../base_interface/db_interface"
require_relative "query_string_error"


module XQuery
  class FunctionProcessor
    
    def initialize(database, collection)
      @database = database
      @collection = collection
    end
    
    
    def doc(path)#:Transformer::Key
      @db = BaseInterface::DBInterface.instance
      all_file_hash = @db.find_value(Transformer::Key.create(@database, @collection, 0).collection_key)
      file_id = nil
      if(all_file_hash != nil)
        file_id = all_file_hash[path]
      end
      if(file_id == nil)
        raise QueryStringError, "file #{file_name} not found in database" 
      end
      return Transformer::Key.create(@database, @collection, file_id)
    end
    
    def not(evaluated_boolean)
      return !evaluated_boolean
    end
    
  end
  
end

