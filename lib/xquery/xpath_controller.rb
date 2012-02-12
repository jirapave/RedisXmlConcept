require_relative "function_processor"
require_relative "specified_predicate"
require_relative "../transformer/key_element_builder"
require_relative "../base_interface/db_interface"

module XQuery
  class XPathController
    
    def initialize(database, collection)
      @function = FunctionProcessor.new(database, collection)
      @db_interface = BaseInterface::DBInterface.instance
    end
    
    def get_results(expression)
      
      @result_list = []
      @key = nil
      
      expression.parts.each_with_index { |step, index|
        case step.subtype
        when Expression::FUNCTION
          if(index == 0 && step.parts[0].name == "doc")
            @key = @function.doc(step.parts[0].parts[0].value)
            puts "generated key: #{key}"
            
          else
            raise QueryStringError, "Error in xpath expression: wrong function in the beginning"
            
          end
          
        when Expression::ELEMENT
          if(index == 0 || @key == nil)
            raise QueryStringError, "Error in xpath expression: wrong init - no key can be generated"
          end
          
          elem_name = step.parts[0].value
          
          if(index == 1 && @key.instance_of?(Transformer::Key))
            
            if(elem_name.empty?)#from this part we know, that we need to search the whole document - so either way set root
              root_name = @db_interface.find_value(@key.info)
              @key = @key.root(root_name)
              #TODO - but first the normal xpath expression resolve
              
            else
              @key = @key.root(elem_name)
              
            end
            
          elsif(index > 1 && @key.instance_of?(Transformer::KeyElementBuilder))
            #TODO key.elem!(...)
            
          else
            raise QueryStringError, "Error in xpath expression: wrong init - no root specified"
            
          end
          
        end
      }
      
      
      #TODO parse structured xpath expression!!
      
      #TODO determine and populate each step - database connection required
      
      #TODO return last step results - strings(atomic values)/elements - greedily loaded
    end
    
    #this specify predicate expressions with SpecifiedPredicate objects
    def specify_predicate(expression)
      if(expression.type != Expression::PREDICATE)
        raise StandardError, "Do not give non-predicate expressions to this method."
      end
      
      #there is one child: index
      if(expression.parts.length == 1 && expression.parts[0].type == Expression::BASIC)
        predicate = IndexPredicate.new(expression.parts[0].value.to_i)
        
      #there is 3 children: binary operator and two sides (string comparison or position...)
      elsif(expression.parts.length == 3 && expression.parts[1].type == Expression::BINARY_OPERATOR)
        if(expression.part[0].type == Expression::BASIC)
          # param1 = 
        end
        
        
      else
        raise StandardError, "this type of predicate is not yet implemented"
        
      end
      
    end
    
  end
end