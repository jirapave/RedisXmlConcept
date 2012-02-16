require_relative "function_processor"
require_relative "db_helper"
require_relative "predicate_processor"
require_relative "../transformer/key_element_builder"
require_relative "../base_interface/db_interface"

module XQuery
  class XPathController
    
    def initialize(database, collection)
      @function = FunctionProcessor.new(database, collection)
      @db_interface = BaseInterface::DBInterface.instance
      @db_helper = nil
    end
    
    def get_results(expression, result_context)
      
      key_array = []
      @last_step = false
      
      expression.parts.each_with_index { |step, index|
        if(index == 0)
          key_array = first_step_keys(step, result_context)
        else
          key_array = next_step_keys(step, key_array)
        end
      }
      
      
      #return last step results - strings(atomic values)/elements - greedily loaded
      results = []
      key_array.each { |key|
        results << @db_helper.get_node(key)
      }
      
      return results
    end
    
    
  private
    
    def first_step_keys(step, result_context)#:Array with KeyElementBuilder as elements
      if(  step.subtype == Expression::FUNCTION \
        && step.name == "doc" \
        && step.parts.length == 1 \
        && step.parts[0].type == Expression::ATOMIC_VALUE \
        && step.parts[0].parts[0].type == AtomicValue::STRING)
        
        key = @function.doc(step.parts[0].parts[0].value) #Key
        key_array = [ key ]
        
        @db_helper = DBHelper.new(key)
        
      elsif(step.subtype == Expression::VARIABLE)
        key_array = result_context.variables[step.name] #TODO needs to be Array
        if(key_array == nil)
          raise QueryStringError, "there is no variable \"#{step.name}\" defined"
        end
        if(!key_array.kind_of?(Array))
          key_array = [ key_array ]
        end
        if(key_array.length > 0)
          key_array.each { |k|
            if(!k.kind_of?(KeyBean)) #KeyBean consists of Key and KeyElementBuilder
              raise QueryStringError, "content of variable is not KeyBean object(s)"
            end
          }
        end
        
      else
        raise QueryStringError, "Wrong function specification in the beginning of this xpath query. Type of expression: #{step.type}" 
      end
      
      return key_array
    end
    
    
    def next_step_keys(step, key_array)
      if(@last_step)
        raise QueryStringError, "additional step (after attribute, function, ... step) is not allowed"
      end
      puts "incomming key_array in next: #{key_array.inspect}"
      
      new_key_array = []
      
      if(step.subtype == Expression::ELEMENT)
        elem_name = step.parts[0]
        
        #check predicate
        predicate = (step.parts.length > 1 && step.parts[1].type == Expression::PREDICATE) ? step.parts[1] : nil
        
        predicated_addition = Proc.new { |context_key, position|
          if(predicate == nil || PredicateProcessor.evaluate(@db_helper, context_key, position, predicate))
            new_key_array << context_key
          end
        }
        
        if(elem_name == nil || elem_name.empty?) #element name is empty - search whole document from this state
          key_array.each { |key|
            if(key.kind_of?(Transformer::KeyElementBuilder))
              new_key_array.concat(@db_helper.get_children_element_keys(key))
            else
              new_key_array << @db_helper.root_key
            end
          }
          
          #iterate until all elements from this level are saved
          next_round_keys = []
          next_round_keys.concat(new_key_array)
          while(!next_round_keys.empty?)
            new_next_round_keys = []
            next_round_keys.each { |key|
              new_child_elements = @db_helper.get_children_element_keys(key)
              new_key_array.concat(new_child_elements)
              new_next_round_keys.concat(new_child_elements)
            }
            next_round_keys = new_next_round_keys
          end
          
          #TODO there is probably no need to check the predicate... find out! 
          
          
        elsif(elem_name == '*') #wildcard for this hierarchy level elements
          key_array.each { |key|
            puts "each #{key}"
            if(key.kind_of?(Transformer::KeyElementBuilder))
              children_element_keys = @db_helper.get_children_element_keys(key)
              children_element_keys.each_with_index { |key, index|
                predicated_addition.call(key, index + 1)
              }
            else
              new_key_array << @db_helper.root_key
            end
            
            #TODO solve predicate
            
          }
          
        else #element name is specified
          elem_id = @db_helper.get_elem_index(elem_name)
          
          key_array.each_with_index { |key, index|
            puts "each #{key}"
            if(key.kind_of?(Transformer::KeyElementBuilder))
              #restriction according previous step children
              children_bean = @db_helper.get_children(key)
              elem_count = children_bean.elem_hash[elem_id]
              if(elem_count != nil)
                elem_count.to_i.times { |i|
                  context_key = Transformer::KeyElementBuilder.build_from_s(key.elem(elem_id, i))
                  predicated_addition.call(context_key, i + 1)
                }
              end
              
            else
              if(@db_helper.root_key.root_name != elem_id)
                raise QueryStringError, "root element name is wrong: #{elem_name}"
              end
              new_key_array << @db_helper.root_key
              
            end
          }
        end
        
      elsif(step.subtype == Expression::ATTRIBUTE) # this should be the last step
        @last_step = true
        attr_name = step.parts[0]
        
        #restriction according previous step children
        key_array.each { |key|
          attr_hash = @db_helper.get_attributes(key)
          value = attr_hash[attr_name]
          if(value != nil)
            new_key_array << attr_hash[attr_name]
          end
        }
        
      elsif(step.subtype == Expression::FUNCTION) #data, text? TODO
        @last_step = true
        #TODO
        raise StandardError, "not yet implemented"
        
      else
        raise QueryStringError, "wrong step type (or unknown by this parser)"
        
      end
      
      puts "   generated #{new_key_array.inspect}"
      return new_key_array
    end
    
    
  end
end