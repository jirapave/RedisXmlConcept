module XQuery
  class SpecifiedPredicate #DEPRICATED
    
    #between more predicates
    LOGIC_AND = :and
    LOGIC_OR = :or
    
    def initialize(db_helper, *predicate_expressions)
      
      predicate_values = []
      predicate_expressions.each { |expr|
        case expr.type
        
        when Expression::BASIC
          predicate_values << expr.parts[0]
          
        when Expression::FUNCTION
          predicate_values << PredicateFunction.new(expr.name, expr.parts)
          
        when Expression::BINARY_OPERATOR
          
          
        end
      }
      
      
    end
    
  end
  
  class PredicateFunction
    
    def initialize(name, *parameters)
      #parameters TODO to be implemented
      @name = name
      @get_value = nil
      
      case name
      when Function::POSITION
        @get_value = Proc.new { |position|
          position
        }
        
      else
        fail StandardError, "function #{name} not implemented"
      end
      
    end
    
    attr_reader :get_value
    
  end
end