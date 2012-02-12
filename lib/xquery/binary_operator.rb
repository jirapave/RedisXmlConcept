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
    
    def which_operator(pattern)#returns OperatorEnum or nil
      if(pattern.lentgh == 1 || pattern.length == 2)
        OPERATORS.each { |x|
           if(x.pattern == pattern)
             return x
           end
        }
      end
      return nil
    end
    
    def evaluate(operator, param1, param2)#returns boolean
      if(!param1.kind_of?(Sequence) || !param2.kind_of?(Sequence))
        raise StandardError, "wrong parameter type"
      end
      
      if(param1.type == Sequence::ATOMIC_VALUE && param2.type == Sequence::ATOMIC_VALUE)
        atomic_type1 = param1.value.type
        atomic_type2 = param2.value.type
      else
        raise StandardError, "non-atomic value comparisons not yet supported"
      end
      
      case operator
      when GLOBAL_EQ
        
      end
    end
    
  end
end