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
      
      @result_list = []
      @key = nil
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
      
      return results #TODO not checked if this all is functioning
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
        key_array = result_context.variables[step.name]
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
      puts "incomming key_array in next: #{key_array.inspect}"
      
      new_key_array = []
      
      if(step.subtype == Expression::ELEMENT)
        elem_name = step.parts[0]
        elem_id = @db_helper.get_elem_index(elem_name)
        
        #check predicate
        predicate = (step.parts.length > 1 && step.parts[1].type == Expression::PREDICATE) ? step.parts[1] : nil
        
        if(elem_name.empty?) #element name is empty - search whole document from this state
          raise StandardError, "to be implemented"
          
        else #element name is specified
          key_array.each { |key|
            puts "each #{key}"
            if(key.instance_of?(Transformer::Key))
              if(@db_helper.root_key.root_name != elem_id)
                raise QueryStringError, "root element name is wrong: #{elem_name}"
              end
              new_key_array << @db_helper.root_key 
            elsif(key.instance_of?(Transformer::KeyElementBuilder))
              #restriction according previous step children
              children_bean = @db_helper.get_children(key)
              elem_count = children_bean.elem_hash[elem_id]
              if(elem_count != nil)
                elem_count.to_i.times { |i|
                  new_key_array << Transformer::KeyElementBuilder.build_from_s(key.elem(elem_id, i))
                }
              else
                raise QueryStringError, "element of name #{elem_name} not found in this context of xml"
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
          
          puts "   generated #{new_key_array.inspect}"
          
          return new_key_array
          
        end
        
      elsif(step.subtype == Expression::ATTRIBUTE)
        #TODO
        
      elsif(step.subtype == Expression::FUNCTION) #data, text? TODO
        #TODO
        
      else
        raise QueryStringError, "wrong step type (or unknown by this parser)"
        
      end
    end
    
    #this specify predicate expressions with SpecifiedPredicate objects
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
      else
        raise StandardError, "not yet implemented"
        
      end
      
      return value
    end
    
    def compare(parameter1, parameter2, binary_operator)
      
    end
    
  end
end