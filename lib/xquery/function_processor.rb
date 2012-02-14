require_relative "../transformer/key_element_builder"
require_relative "../base_interface/db_interface"
require_relative "query_string_error"


module XQuery
  class FunctionProcessor
    
    def initialize(database, collection)
      @database = database
      @collection = collection
    end
    
    # def process(function_string) #:TypedResult - returns what the function should return (TypedResult)
      # first_parenthesis_index = function_string.index('(')
#       
      # #0 to indexof first parenthesis is function name
      # function_name = function_string[0..first_parenthesis_index-1]
#       
      # #the rest in the parenthesis - parameters
      # function_params = function_string[first_parenthesis_index+1..-2].split(',')
      # param1 = param2 = param3 = nil
      # if(function_params.length > 0)
        # param1 = function_params[0].strip
        # if(param1[0] == "\"" || param1[0] == "\'")
          # param1 = param1[1..-2]
        # end
#         
        # #next params
        # if(function_params.length > 1)
          # param2 = function_params[1].strip
#           
          # if(function_params.length > 2)
            # param3 = function_params[2].strip
          # end
        # end
#         
      # end
#       
#       
#       
      # case function_name
      # when "doc"
        # if(param1 == nil || param2 != nil)
          # raise QueryStringError, "wrong number of parameters for function doc(path), function string: #{function_string}"
        # end
        # return doc(param1)
      # when "not"
        # if(param1 == nil || param2 != nil)
          # raise QueryStringError, "wrong number of parameters for function not(boolean), function string: #{function_string}"
        # end
        # return not(param1) #TODO wrong impl. so far
      # when "position"
        # if(param1 != nil)
          # raise QueryStringError, "wrong number of parameters for function position(), function string: #{function_string}"
        # end
        # return "position"
      # end
#       
      # raise QueryStringError, "unrecognised function name for function string: #{function_string}"
#       
    # end
    
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
  
  # class TypedResult
    # DOC = 1
#     
    # def initialize(type, result)
      # @type = type
      # @result = result
    # end
#     
    # attr_reader :type, :result
#     
  # end
  
end

