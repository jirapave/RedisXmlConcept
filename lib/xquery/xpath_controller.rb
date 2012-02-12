require_relative "function_processor"
require_relative "../transformer/key_element_builder"

module XQuery
  class XPathController
    
    def initialize(database, collection)
      @function = FunctionProcessor.new(database, collection)
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
          
          if(index == 1 && @key.instance_of?(Transformer::KeyElementBuilder))
            if(elem_name.empty?)
            end
            @key = @key.root()
          end
          
        end
      }
      
      
      #TODO parse structured xpath expression!!
      
      #TODO determine and populate each step - database connection required
      
      #TODO return last step results - strings(atomic values)/elements - greedily loaded
    end 
    
  end
end