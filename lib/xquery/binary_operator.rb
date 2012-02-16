require_relative "query_string_error"
require_relative "sequence"

module XQuery
  class BinaryOperator
    
    class OperatorEnum
      def initialize(pattern)
        @pattern = pattern
      end
      attr_reader :pattern
    end
    
    GLOBAL_EQ = OperatorEnum.new("=")
    GLOBAL_NE = OperatorEnum.new("!=")
    GLOBAL_GT = OperatorEnum.new(">")
    GLOBAL_GE = OperatorEnum.new(">=")
    GLOBAL_LT = OperatorEnum.new("<")
    GLOBAL_LE = OperatorEnum.new("<=")
    
    VALUE_EQ = OperatorEnum.new("eq")
    VALUE_NE = OperatorEnum.new("ne")
    VALUE_GT = OperatorEnum.new("gt")
    VALUE_GE = OperatorEnum.new("ge")
    VALUE_LT = OperatorEnum.new("lt")
    VALUE_LE = OperatorEnum.new("le")
    
    LOGIC_AND = OperatorEnum.new("and") # preference over OR
    LOGIC_OR = OperatorEnum.new("or")
    
    OPERATORS = [GLOBAL_EQ, GLOBAL_NE, GLOBAL_GT, GLOBAL_GE, GLOBAL_LT, GLOBAL_LE,
                 VALUE_EQ , VALUE_NE , VALUE_GT , VALUE_GE , VALUE_LT , VALUE_LE,
                 LOGIC_AND, LOGIC_OR]
    
    def self.which_operator(pattern)#returns OperatorEnum or nil
      if(pattern == nil)
        fail StandardError, "pattern cannot be nil"
      end
      if(pattern.respond_to?(:pattern))
        return pattern
      end
      if(pattern.length == 1 || pattern.length == 2)
        OPERATORS.each { |x|
           if(x.pattern == pattern)
             return x
           end
        }
      end
      return nil
    end
    
    #operator can be String or OperatorEnum
    def self.evaluate(operator, param1, param2)#returns boolean
      if(  !param1.respond_to?(:type) || !param2.respond_to?(:type) \
        || (!param1.respond_to?(:value) && !param1.respond_to?(:values)) \
        || (!param2.respond_to?(:value) && !param2.respond_to?(:values)) )
        raise StandardError, "wrong parameter type" #parameters should be Sequences or AtomicValues
      end
      
      operator = which_operator(operator)
      
      if(operator == nil)
        raise StandardError, "operator is nil"
      end
      
      case operator
      when GLOBAL_EQ, GLOBAL_NE, GLOBAL_GT, GLOBAL_GE, GLOBAL_LT, GLOBAL_LE
        if(param1.respond_to?(:values))
          param1.values.each { |value1|
            if(param2.respond_to?(:values))
              param2.values.each { |value2|
                result = try_coerce_solve(operator, value1, value2)
                return true if(result)
              }
            else
              result = try_coerce_solve(operator, value1, param2.value)
              return true if(result)
            end
          }
        else
          if(param2.respond_to?(:values))
            param2.values.each { |value2|
              result = try_coerce_solve(operator, param1.value, value2)
              return true if(result)
            }
          else
            return try_coerce_solve(operator, param1.value, param2.value)
          end
        end
        return false
        
      when VALUE_EQ, VALUE_NE, VALUE_GT, VALUE_GE, VALUE_LT, VALUE_LE
        if(param1.respond_to?(:values) || param2.respond_to?(:values))
          raise TypeError.new("parameters cannot be sequences - maybe you want to use a GLOBAL comparison")
        end
        param1.value = normalize_value_type(param1)
        param2.value = normalize_value_type(param2)
        if(param1.type == param2.type)
          raise TypeError.new("parameters are different type - maybe you want to use a GLOBAL comparison")
        end
        return value_comparison(operator, param1.value, param2.value)
      else
        fail StandardError, "to be implemented"
        
      end
      
    end
    
    
    def self.normalize_value_type(param)
      if(param.type == AtomicValue::UNTYPED)
        return param.value.to_s
      end
      return param.value
    end
    
    def self.value_comparison(operator, param1, param2)
      case operator
      when VALUE_EQ
        return param1 == param2
      when VALUE_NE
        return param1 != param2
      when VALUE_GT
        return param1 > param2
      when VALUE_GE
        return param1 >= param2
      when VALUE_LT
        return param1 < param2
      when VALUE_LE
        return param1 <= param2
      else
        raise StandardError, "wrong operator #{operator}"
      end
    end
    
    def self.try_coerce_solve(operator, param1, param2)
      no1 = make_number(param1)
      if(no1 != nil)
        no2 = make_number(param2)
        if(no2 != nil)
          param1 = no1
          param2 = no2 
        end
      end
      
      case operator
      when GLOBAL_EQ
        return param1 == param2
      when GLOBAL_NE
        return param1 != param2
      when GLOBAL_GT
        return param1 > param2
      when GLOBAL_GE
        return param1 >= param2
      when GLOBAL_LT
        return param1 < param2
      when GLOBAL_LE
        return param1 <= param2
      else
        raise StandardError, "wrong operator #{operator}"
      end
      
    end
    
    def self.make_number(param)
      begin
        Float(param)
      rescue
        nil
      end
    end
    
  end
end