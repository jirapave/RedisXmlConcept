require_relative "function_processor"
require_relative "db_helper"
require_relative "predicate_processor"
require_relative "../transformer/key_element_builder"
require_relative "../base_interface/db_interface"

module XQuery
  class XPathController
    
    attr_reader :db_helper
    
    def initialize(database, collection)
      @function = FunctionProcessor.new(database, collection)
      @db_helper = nil
    end
    
    def get_results(expression, result_context)
      
      @last_step = false
      result_array = []
      
      expression.parts.each_with_index { |step, index|
        if(index == 0)
          result_array = first_step(step, result_context)
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
          results << @db_helper.get_node(key)
        else
          results << key
        end
        
      }
      
      return results
    end
    
    
  private
    
    def first_step(step, result_context)#:Array with KeyElementBuilder as elements
      if(  step.subtype == Expression::FUNCTION \
        && step.name == "doc" \
        && step.parts.length == 1 \
        && step.parts[0].type == Expression::ATOMIC_VALUE \
        && step.parts[0].parts[0].type == AtomicValue::STRING)
        
        key = @function.doc(step.parts[0].parts[0].value) #Key
        result_array = [ key ]
        
        @db_helper = DBHelper.new(key)
        
      elsif(step.subtype == Expression::VARIABLE)
        result_array = result_context.variables[step.name] #Array of nodes
        if(result_array == nil)
          raise QueryStringError, "there is no variable \"#{step.name}\" defined"
        end
        if(result_array.kind_of?(Array))
          result_array = [ result_array ]
        end
        
        @node_helper = NodeHelper.new
        
      else
        raise QueryStringError, "Wrong function specification in the beginning of this xpath query. Type of expression: #{step.type}" 
      end
      
      return result_array
    end
    
    
    def next_step_keys(step, key_array)
      if(@last_step)
        raise QueryStringError, "additional step (after attribute, function, ... step) is not allowed"
      end
      
      puts "incomming key_array #{key_array.inspect}"
      
      new_key_array = []
      
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
            key_array.each { |key|
              #TODO maybe handle predicate?
              text_content = @db_helper.get_text(key)
              if(!text_content.empty?)
                new_key_array << text_content
              end
            }
            
          else
            raise StandardError, "not yet implemented"
          end
          
          return new_key_array
        end
        
        predicated_addition = Proc.new { |context_key, position, max_position|
          if(predicate == nil || PredicateProcessor.evaluate(@db_helper, context_key, position, max_position, predicate))
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
            if(key.kind_of?(Transformer::KeyElementBuilder))
              children_element_keys = @db_helper.get_children_element_keys(key)
              children_element_keys.each_with_index { |key, index|
                predicated_addition.call(key, index + 1, children_element_keys.length)
              }
            else
              new_key_array << @db_helper.root_key
            end
            
            #TODO solve predicate
            
          }
          
        else #element name is specified
          elem_id = @db_helper.get_elem_index(elem_name)
          
          key_array.each_with_index { |key, index|
            if(key.kind_of?(Transformer::KeyElementBuilder))
              #restriction according previous step children
              children_bean = @db_helper.get_children(key)
              elem_count = children_bean.elem_hash[elem_id]
              if(elem_count != nil)
                elem_count.to_i.times { |i|
                  context_key = Transformer::KeyElementBuilder.build_from_s(key.elem(elem_id, i))
                  predicated_addition.call(context_key, i + 1, elem_count.to_i)
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
        attr_name = step.name
        
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
        
        case step.name
        when "#{Function::TEXT}"
          key_array.each { |key|
            children_bean = @db_helper.get_children(key)
            text_content = children_bean.text_array.join.strip #TODO strip, really?
            if(!text_content.empty?)
              new_key_array << text_content
            end
          }
          
          
        else
          raise StandardError, "not yet implemented"
        end
        
      else
        raise QueryStringError, "wrong step type (or unknown by this parser)"
        
      end
      
      return new_key_array
    end
    
    
    def next_step_nodes(step, node_array)
      if(@last_step)
        raise QueryStringError, "additional step (after attribute, function, ... step) is not allowed"
      end
      
      new_node_array = []
      
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
            node_array.each { |node|
              #TODO maybe handle predicate?
              text_content = @node_helper.get_text(node)
              if(!text_content.empty?)
                new_node_array << text_content
              end
            }
            
          else
            raise StandardError, "not yet implemented"
          end
          
          return new_node_array
        end
        
        #TODO continue - node kind of this method!
        
        predicated_addition = Proc.new { |context_node, position, max_position|
          if(predicate == nil || PredicateProcessor.evaluate(@node_helper, context_node, position, max_position, predicate))
            new_node_array << context_node
          end
        }
        
        if(elem_name == nil || elem_name.empty?) #element name is empty - search whole document from this state
          node_array.each { |key|
            if(key.kind_of?(Transformer::KeyElementBuilder))
              new_node_array.concat(@db_helper.get_children_element_keys(key))
            else
              new_node_array << @db_helper.root_key
            end
          }
          
          #iterate until all elements from this level are saved
          next_round_nodes = []
          next_round_nodes.concat(new_node_array)
          while(!next_round_nodes.empty?)
            new_next_round_nodes = []
            next_round_nodes.each { |key|
              new_child_elements = @db_helper.get_children_element_keys(key)
              new_node_array.concat(new_child_elements)
              new_next_round_nodes.concat(new_child_elements)
            }
            next_round_nodes = new_next_round_nodes
          end
          
          #TODO there is probably no need to check the predicate... find out! 
          
          
        elsif(elem_name == '*') #wildcard for this hierarchy level elements
          node_array.each { |key|
            if(key.kind_of?(Transformer::KeyElementBuilder))
              children_element_keys = @db_helper.get_children_element_keys(key)
              children_element_keys.each_with_index { |key, index|
                predicated_addition.call(key, index + 1, children_element_keys.length)
              }
            else
              new_node_array << @db_helper.root_key
            end
            
            #TODO solve predicate
            
          }
          
        else #element name is specified
          elem_id = @db_helper.get_elem_index(elem_name)
          
          node_array.each_with_index { |key, index|
            if(key.kind_of?(Transformer::KeyElementBuilder))
              #restriction according previous step children
              children_bean = @db_helper.get_children(key)
              elem_count = children_bean.elem_hash[elem_id]
              if(elem_count != nil)
                elem_count.to_i.times { |i|
                  context_key = Transformer::KeyElementBuilder.build_from_s(key.elem(elem_id, i))
                  predicated_addition.call(context_key, i + 1, elem_count.to_i)
                }
              end
              
            else
              if(@db_helper.root_key.root_name != elem_id)
                raise QueryStringError, "root element name is wrong: #{elem_name}"
              end
              new_node_array << @db_helper.root_key
              
            end
          }
        end
        
      elsif(step.subtype == Expression::ATTRIBUTE) # this should be the last step
        @last_step = true
        attr_name = step.name
        
        #restriction according previous step children
        node_array.each { |key|
          attr_hash = @db_helper.get_attributes(key)
          value = attr_hash[attr_name]
          if(value != nil)
            new_node_array << attr_hash[attr_name]
          end
        }
        
      elsif(step.subtype == Expression::FUNCTION) #data, text? TODO
        @last_step = true
        
        case step.name
        when "#{Function::TEXT}"
          node_array.each { |key|
            children_bean = @db_helper.get_children(key)
            text_content = children_bean.text_array.join.strip #TODO strip, really?
            if(!text_content.empty?)
              new_node_array << text_content
            end
          }
          
          
        else
          raise StandardError, "not yet implemented"
        end
        
      else
        raise QueryStringError, "wrong step type (or unknown by this parser)"
        
      end
      
      return new_node_array
    end
    
    
  end
end