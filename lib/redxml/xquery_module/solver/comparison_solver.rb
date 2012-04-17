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
      
      values1.each { |value1|
        values2.each { |value2|
          
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
    
    
    def self.evaluate_general_comp(value1, operator, value2)
      value1 = value1.text
      value2 = value2.text
      no1 = make_number(value1)
      if(no1 != nil)
        no2 = make_number(value2)
        if(no2 != nil)
          value1 = no1
          value2 = no2
        else
          value1 = value1.to_s
          value2 = value2.to_s
        end
      else
        value1 = value1.to_s
        value2 = value2.to_s
      end
      
      
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