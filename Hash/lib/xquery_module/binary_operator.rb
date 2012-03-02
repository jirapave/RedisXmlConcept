require_relative "exceptions"
require_relative "sequence"
require_relative "helper"

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
    
    
    GLOBAL_OPERATORS = [GLOBAL_EQ, GLOBAL_NE, GLOBAL_GT, GLOBAL_GE, GLOBAL_LT, GLOBAL_LE ]
    VALUE_OPERATORS = [VALUE_EQ , VALUE_NE , VALUE_GT , VALUE_GE , VALUE_LT , VALUE_LE]
    LOGIC_OPERATORS = [LOGIC_AND, LOGIC_OR]
    
    NAME_OPERATORS = VALUE_OPERATORS | LOGIC_OPERATORS
    
    OPERATORS = GLOBAL_OPERATORS | NAME_OPERATORS
    
                 
    def self.is_operator_name?(pattern)
      if(pattern.length == 2 || pattern.length == 3)
        NAME_OPERATORS.each { |x|
           if(x.pattern == pattern)
             return true
           end
        }
      end
      return false
    end
    
    def self.which_operator(pattern)#returns OperatorEnum or nil
      if(pattern == nil)
        fail StandardError, "pattern cannot be nil"
      end
      if(pattern.kind_of?(OperatorEnum))
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
      if(  (!param1.kind_of?(AtomicValue) && !param1.kind_of?(Sequence)) \
        || (!param2.kind_of?(AtomicValue) && !param2.kind_of?(Sequence)) )
        raise StandardError, "wrong parameter type" #parameters should be Sequences or AtomicValues
      end
      
      operator = which_operator(operator)
      
      puts "BINARY OPERATOR: #{param1.inspect} #{operator.pattern} #{param2.inspect}"
      
      if(operator == nil)
        raise StandardError, "operator is nil"
      end
      
      case operator
      when GLOBAL_EQ, GLOBAL_NE, GLOBAL_GT, GLOBAL_GE, GLOBAL_LT, GLOBAL_LE
        if(param1.kind_of?(Sequence))
          param1.values.each { |value1|
            if(param2.kind_of?(Sequence))
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
          if(param2.kind_of?(Sequence))
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
        if(param1.kind_of?(Sequence) || param2.kind_of?(Sequence))
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
      no1 = Helper.make_number(param1)
      if(no1 != nil)
        no2 = Helper.make_number(param2)
        if(no2 != nil)
          param1 = no1
          param2 = no2
        else
          param1 = param1.to_s
          param2 = param2.to_s
        end
      else
        param1 = param1.to_s
        param2 = param2.to_s
      end
      
      puts "#{param1} ... #{param2}"
      
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
    
  end
end