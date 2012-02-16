module XQuery
  class PredicateProcessor
    
    def self.evaluate(db_helper, context_key, position, predicate_expression)
      
      last_val = nil
      operator = nil
      predicate_expression.parts.each { |expr|
        case expr.type
        
        when Expression::BASIC
          if(last_val == nil)
            last_val = AtomicValue.new(expr.parts[0])
          else
            return BinaryOperator.evaluate(operator, last_val, AtomicValue.new(expr.parts[0]))
          end
        
        when Expression::ATOMIC_VALUE
          if(last_val == nil)
            last_val = expr.parts[0]
          else
            return BinaryOperator.evaluate(operator, last_val, expr.parts[0])
          end
          
        when Expression::ATTRIBUTE
          attribute_hash = db_helper.get_attributes(context_key)
          attr_val = attribute_hash[expr.parts[0]]
          if(attr_val == nil)
            raise QueryStringError, "attribute #{expr.parts[0]} not found"
          end
          if(last_val == nil)
            last_val = AtomicValue.new(attr_val)
          else
            return BinaryOperator.evaluate(operator, last_val, AtomicValue.new(attr_val))
          end
        
        when Expression::BINARY_OPERATOR
          operator = expr.parts[0]
          
        when Expression::FUNCTION
          case expr.name
            
          when "#{Function::POSITION}"
            if(last_val == nil)
              last_val = AtomicValue.new(position, AtomicValue::NUMERIC)
            else
              return BinaryOperator.evaluate(operator, last_val, position)
            end
            
          else
            raise StandardError, "function #{expr.name} not implemented"
          end
          
        else
          fail StandardError, "other type of expression not yet implemented here (#{expr.type})"
          
        end
      }
      
      #TODO add support for more complex predicates
      
    end
    
  end
end