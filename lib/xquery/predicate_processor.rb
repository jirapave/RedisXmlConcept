require_relative "helper"
require_relative "binary_operator"

module XQuery
  class PredicateProcessor
    
    def self.evaluate(xpath_processor, context_elem, position, max_position, predicate_expression)
      
      last_val = nil
      operator = nil
      predicate_expression.parts.each { |expr|
        case expr.type
        
        when Expression::BASIC
          if(expr.parts[0] == '.')
            value = AtomicValue.new(xpath_processor.get_node_content(context_elem)) 
          elsif(!Helper.is_number?(expr.parts[0])) #element name
            value = Sequence.new
            new_elements = xpath_processor.get_children_elements(context_elem, expr.parts[0])
            new_elements.each { |elem|
              content = xpath_processor.get_node_content(elem)
              value.values << content
            }
            
            # context_children_bean = xpath_processor.get_children(context_elem)
            # elem_id = xpath_processor.get_elem_index(expr.parts[0])
            # elem_count = context_children_bean.elem_hash[elem_id]
            # if(elem_count == nil)
              # raise QueryStringError, "wrong element in predicate (#{expr.parts[0]})"
            # end
            # value = Sequence.new
            # elem_count.to_i.times { |i|
              # new_key = Transformer::KeyElementBuilder.build_from_s(context_elem.elem(elem_id, i))
              # content = xpath_processor.get_node_content(new_key)
              # value.values << content
            # }
            
            if(value.values.length == 1)
              value = AtomicValue.new(value.values[0])
            end
          else #number
            value = AtomicValue.new(Helper.make_number(expr.parts[0]), AtomicValue::NUMERIC)
          end
          if(last_val == nil)
            last_val = value
          else
            last_val = BinaryOperator.evaluate(operator, last_val, value)
          end
        
        when Expression::ATOMIC_VALUE
          if(last_val == nil)
            last_val = expr.parts[0]
          else
            last_val = BinaryOperator.evaluate(operator, last_val, expr.parts[0])
          end
          
        when Expression::ATTRIBUTE
          attribute_hash = xpath_processor.get_attribute_hash(context_elem)
          attr_val = attribute_hash[expr.name]
          if(attr_val == nil)
            raise QueryStringError, "attribute #{expr.name} not found"
          end
          if(last_val == nil)
            last_val = AtomicValue.new(attr_val)
          else
            last_val = BinaryOperator.evaluate(operator, last_val, AtomicValue.new(attr_val))
          end
        
        when Expression::BINARY_OPERATOR
          operator = expr.name
          
        when Expression::FUNCTION
          case expr.name
            
          when "#{Function::POSITION}"
            value = AtomicValue.new(position, AtomicValue::NUMERIC)
            if(last_val == nil)
              last_val = value
            else
              last_val = BinaryOperator.evaluate(operator, last_val, value)
            end
            
          when "#{Function::LAST}"
            value = AtomicValue.new(max_position, AtomicValue::NUMERIC)
            if(last_val == nil)
              if(predicate_expression.parts.length == 1) #last is the only function
                return position == max_position
              end
              last_val = value
            else
              last_val = BinaryOperator.evaluate(operator, last_val, value)
            end
            
          else
            raise StandardError, "function #{expr.name} not implemented"
          end
          
        else
          raise StandardError, "other type of expression not yet implemented here (#{expr.type})"
          
        end
      }
      
      if(last_val == nil || !Helper.is_boolean?(last_val))
        raise QueryStringError, "predicate not set right #{last_val}"
      end
      
      return last_val
      
      #TODO add support for more complex predicates
      
    end
    
  end
end