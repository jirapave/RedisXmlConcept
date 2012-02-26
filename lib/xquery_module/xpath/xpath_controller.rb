require_relative "../xquery/function_processor"
require_relative "key_xpath_processor"
require_relative "node_xpath_processor"
require_relative "predicate_processor"
require_relative "../../transformer/key_element_builder"

module XQuery
  class XPathController
    
    attr_reader :xpath_processor
    
    def initialize(environment, collection)
      @function = FunctionProcessor.new(environment, collection)
      @xpath_processor = nil
    end
    
    def get_results(expression, variable_hash=Hash.new)
      
      @last_step = false
      result_array = []
      
      expression.parts.each_with_index { |step, index|
        if(index == 0)
          result_array = first_step(step, variable_hash)
        else
          result_array = next_step_keys(step, result_array)
        end
        if(result_array.empty?)
          break
        end
      }
      
      
      #return last step results - strings(atomic values)/elements - greedily loaded
      results = []
      result_array.each { |key|
        if(key.kind_of?(Transformer::KeyElementBuilder))
          results << @xpath_processor.get_node(key)
        else
          results << key
        end
      }
      
      return results
    end
    
    
  private
    
    def first_step(step, variable_hash)#:Array with KeyElementBuilder as elements
      if(  step.subtype == Expression::FUNCTION \
        && step.name == "doc" \
        && step.parts.length == 1 \
        && step.parts[0].type == Expression::ATOMIC_VALUE \
        && step.parts[0].parts[0].type == AtomicValue::STRING)
        
        key = @function.doc(step.parts[0].parts[0].value) #Key
        result_array = [ key ]
        
        @xpath_processor = KeyXPathProcessor.new(key)
        
      elsif(step.subtype == Expression::VARIABLE)
        result_array = variable_hash[step.name] #Array of nodes
        if(result_array == nil)
          raise QueryStringError, "there is no variable \"#{step.name}\" defined"
        end
        if(!result_array.kind_of?(Array))
          result_array = [ result_array ]
        end
        
        @xpath_processor = NodeXPathProcessor.new
        
      else
        raise QueryStringError, "Wrong function specification in the beginning of this xpath query. Type of expression: #{step.type}" 
      end
      
      return result_array
    end
    
    
    def next_step_keys(step, elements)
      if(@last_step)
        raise QueryStringError, "additional step (after attribute, function, ... step) is not allowed"
      end
      
      new_elements = []
      
      if(step.subtype == Expression::ELEMENT)
        elem_name = step.name
        first_part = step.parts.empty? ? nil : step.parts[0] 
        
        #check predicate
        predicate = (step.parts.length > 0 && step.parts[0].type == Expression::PREDICATE) ? step.parts[0] : nil
        
        #is there a function?
        if(first_part != nil && first_part.kind_of?(Expression) && first_part.type == Expression::FUNCTION)#text(), data() ?
          @last_step = true
        
          case first_part.name
          when "#{Function::TEXT}"
            elements.each { |elem|
              text_content = @xpath_processor.get_text(elem, true)
              if(!text_content.empty?)
                new_elements << text_content
              end
            }
            
          else
            raise StandardError, "not yet implemented"
          end
          
          return new_elements
        end
        
        predicated_addition = Proc.new { |context_elem, position, max_position|
          if(predicate == nil || PredicateProcessor.evaluate(@xpath_processor, context_elem, position, max_position, predicate))
            new_elements << context_elem
          end
        }
        
        if(elem_name == nil || elem_name.empty?) #element name is empty - search whole document from this state
          elements.each { |key|
            new_elements.concat(@xpath_processor.get_descendant_elements(key)) 
          }
          
        else #elem_name is * wildcard or valid name
          elements.each { |key|
            children_elements = @xpath_processor.get_children_elements(key, elem_name)
            children_elements_count = children_elements.length
            children_elements.each_with_index { |key, index|
              predicated_addition.call(key, index + 1, children_elements_count)
            }
          }
        end
        
      elsif(step.subtype == Expression::ATTRIBUTE) # this should be the last step
        @last_step = true
        attr_name = step.name
        
        #restriction according previous step children
        elements.each { |elem|
          value = @xpath_processor.get_attribute(elem, attr_name)
          if(value != nil)
            new_elements << value
          end
        }
        
        
      else
        raise QueryStringError, "wrong step type (or unknown by this parser)"
        
      end
      
      return new_elements
    end
    
    
    
  end
end