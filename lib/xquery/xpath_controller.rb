require_relative "function_processor"
require_relative "specified_predicate"
require_relative "db_helper"
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
        if(key_array.respond_to_missing?(:each))
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
      puts "incomming key_array in next: #{key_array.inspect}"
      
      new_key_array = []
      
      if(step.subtype == Expression::ELEMENT)
        elem_name = step.parts[0]
        
        #check predicate
        predicate = (step.parts.length > 1 && step.parts[1].type == Expression::PREDICATE) ? step.parts[1] : nil
        
        if(elem_name == nil || elem_name.empty?) #element name is empty - search whole document from this state
          key_array.each { |key|
            if(key.respond_to?(:document_key)) #
              new_key_array << @db_helper.root_key
            elsif(key.respond_to?(:root_key))
              new_key_array.concat(@db_helper.get_children_element_keys(key))
            else
              raise StandardError, "wrong key format #{key.class}"
            end
          }
          
          #iterate until all elements from this level are saved
          next_round_keys = []
          next_round_keys.concat(new_key_array)
          while(!next_round_keys.empty?)
            new_next_round_keys = []
            next_round_keys.each { |key|
              if(key.respond_to?(:root_key))
                new_child_elements = @db_helper.get_children_element_keys(key)
                new_key_array.concat(new_child_elements)
                new_next_round_keys.concat(new_child_elements)
              else
                raise StandardError, "wrong key format #{key.class}"
              end
            }
            next_round_keys = new_next_round_keys
          end
          
          #TODO there is probably no need to check the predicate... find out! 
          
          
        elsif(elem_name == '*') #wildcard for this hierarchy level elements
          key_array.each { |key|
            puts "each #{key}"
            if(key.respond_to?(:document_key))
              new_key_array << @db_helper.root_key
            elsif(key.respond_to?(:root_key))
              new_key_array.concat(@db_helper.get_children_element_keys(key))
            else
              raise StandardError, "wrong key format #{key.class}"
            end
            
            #TODO solve predicate
            
          }
          
        else #element name is specified
          elem_id = @db_helper.get_elem_index(elem_name)
          
          key_array.each { |key|
            puts "each #{key}"
            if(key.respond_to?(:document_key))
              if(@db_helper.root_key.root_name != elem_id)
                raise QueryStringError, "root element name is wrong: #{elem_name}"
              end
              new_key_array << @db_helper.root_key 
            elsif(key.respond_to?(:root_key))
              #restriction according previous step children
              children_bean = @db_helper.get_children(key)
              elem_count = children_bean.elem_hash[elem_id]
              if(elem_count != nil)
                puts "found"
                elem_count.to_i.times { |i|
                  new_key_array << Transformer::KeyElementBuilder.build_from_s(key.elem(elem_id, i))
                }
                
              # else #this branch is blind, nothing adding to new_key_array
              end
            else
              raise StandardError, "wrong key format #{key.class}"
            end
            
            #check predicates, then generate KeyElementBuilder objects from ChildrenBean and add them to result key_array and move on
            #TODO check above, not here
            if(predicate != nil)
              raise StandardError, "not yet implemented"
              #TODO iterate for predicate
            end
          }
          
        end
        
      elsif(step.subtype == Expression::ATTRIBUTE) # this should be the last step
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
        #TODO
        raise StandardError, "not yet implemented"
        
      else
        raise QueryStringError, "wrong step type (or unknown by this parser)"
        
      end
      
      puts "   generated #{new_key_array.inspect}"
      return new_key_array
      
    end
    
    #this specify predicate expressions with SpecifiedPredicate objects
    #TODO we do this other way
    def specify_predicate(expression)
      if(expression.type != Expression::PREDICATE)
        raise StandardError, "Do not give non-predicate expressions to this method."
      end
      
      #there is one child: index
      if(expression.parts.length == 1 && expression.parts[0].type == Expression::BASIC)
        predicate = IndexPredicate.new(expression.parts[0].parts[0].value.to_i)
        
      #there is 3 children: binary operator and two sides (string comparison or position...)
      elsif(expression.parts.length == 3 && expression.parts[1].type == Expression::BINARY_OPERATOR)
        param1 = get_value(expression.parts[0])
        param2 = get_value(expression.parts[2])
        
        compared = compare(param1, param2, BinaryOperator.which_operator(expression.parts[1].parts[0]))#TODO
        
      else
        raise StandardError, "this type of predicate is not yet implemented"
        
      end
      
    end
    
    def get_value(expression)
      value = nil
      if(expression.type == Expression::BASIC) #probably number
        value = expression.parts[0].value.to_i
        
      elsif(expression.type == Expression::ATOMIC_VALUE)
        value = expression.parts[0].value
        
      elsif(expression.type == Expression::FUNCTION)
        case expression.name
        when Function::POSITION
          value = Function::POSITION
        when Function::NOT
          value = FunctionProcessor.not(expression.parts[0])
        end
        
      else #
        raise StandardError, "not yet implemented"
        
      end
      
      return value
    end
    
    def compare(parameter1, parameter2, binary_operator)
      
    end
    
  end
end