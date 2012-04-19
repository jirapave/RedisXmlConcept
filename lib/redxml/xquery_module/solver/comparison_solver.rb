require_relative "../expression/expression_module"

module XQuery
  class ComparisonSolver
    
    GENERAL_EQ = "="
    GENERAL_NE = "!="
    GENERAL_GT = ">"
    GENERAL_GE = ">="
    GENERAL_LT = "<"
    GENERAL_LE = "<="
    
    VALUE_EQ = "eq"
    VALUE_NE = "ne"
    VALUE_GT = "gt"
    VALUE_GE = "ge"
    VALUE_LT = "lt"
    VALUE_LE = "le"
    
    def self.evaluate(values1, operator, values2) #returns true or false
      
      if(operator.type == ExpressionModule::ValueComp \
         && (values1.length > 1 || values2.length > 1))
         raise TypeError, "unable to compare sequences with more then one item with respect to VALUE comparison"
      end
      
      values1.each { |value1|
        values2.each { |value2|
          
          # puts "comparison: #{value1.text}:#{value1.type} vs #{value2.text}:#{value2.type}"
          
          case operator.type
          when ExpressionModule::ValueComp
            if(value1.type == value2.type && value1.type != ExpressionModule::Literal)
              result = evaluate_value_comp(value1, operator, value2)
              return true if(result) 
            else
              raise TypeError, "value comp cannot compare different types of values"
            end
              
          when ExpressionModule::GeneralComp
            result = evaluate_general_comp(value1, operator, value2)
            return true if(result)
            
          else
            raise StandardError, "impossible - other type of comparison: #{operator.type}"
            
          end
          
        }
      }
      
      return false
    end
    
    
  private
    def self.evaluate_value_comp(value1, operator, value2)
      case operator.text
      when VALUE_EQ
        return value1.text == value2.text
      when VALUE_NE
        return value1.text != value2.text
      when VALUE_GT
        return value1.text > value2.text
      when VALUE_GE
        return value1.text >= value2.text
      when VALUE_LT
        return value1.text < value2.text
      when VALUE_LE
        return value1.text <= value2.text
      else
        raise StandardError, "not possible or implemented"
      end
    end
    
    
    def self.evaluate_general_comp(val1, operator, val2)
      value1 = nil
      value2 = nil
      if(val1.type == ExpressionModule::NumericLiteral)
        #try to cast value2 to numeric
        value2 = make_number(val2.text)
        if(!value2)
          raise TypeError, "unable to cast '#{val2.text}' to numeric value while comparing with: #{val1.text}"
        end
        value1 = make_number(val1.text)
        
      elsif(val2.type == ExpressionModule::NumericLiteral)
        #try to cast value1 to numeric
        value1 = make_number(val1.text)
        if(!value1)
          raise TypeError, "unable to cast '#{val1.text}' to numeric value while comparing with: #{val2.text}"
        end
        value2 = make_number(val2.text)
        
      else
        value1 = val1.text
        value2 = val2.text
        
      end
      # value1 = value1.text
      # value2 = value2.text
      # no1 = make_number(value1)
      # if(no1 != nil)
        # no2 = make_number(value2)
        # if(no2 != nil)
          # value1 = no1
          # value2 = no2
        # else
          # value1 = value1.to_s
          # value2 = value2.to_s
        # end
      # else
        # value1 = value1.to_s
        # value2 = value2.to_s
      # end
      
      
      case operator.text
      when GENERAL_EQ
        return value1 == value2
      when GENERAL_NE
        return value1 != value2
      when GENERAL_GT
        return value1 > value2
      when GENERAL_GE
        return value1 >= value2
      when GENERAL_LT
        return value1 < value2
      when GENERAL_LE
        return value1 <= value2
      else
        raise StandardError, "operator not possible or implemented: #{operator.text}"
      end
    end
    
    
    
    def self.is_number?(value)
      value.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end
    
    def self.make_number(value)
      begin
        return Integer(value)
      rescue
        begin
          return Float(value)
        rescue
          return nil
        end
      end
    end
    
  end
end