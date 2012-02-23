require_relative "../expression"
require_relative "../exceptions"
require_relative "../helper"

module XQuery
  class FLWORController
    
    STATE_FOR = 1
    STATE_LET = 2
    STATE_WHERE = 3
    STATE_ORDER_BY = 4
    STATE_RETURN = 5
    
    def initialize(xpath_controller)
      @xpath_controller = xpath_controller
    end
    
    def get_results(expression, result_context)
      state = 0
      expression.parts.each { |clause|
        case clause.type
          
        when Expression::FOR
          if(state >= STATE_FOR)
            raise QueryStringError, "FLWOR not organized well"
          end
          
          #we have most likely xpath query in value attribute of FOR clause
          #solve this query, store it to variable (into the result_context object)
          xpath_results = @xpath_controller.get_results(clause.value)
          
          #DEBUG TODO delete
          Helper.print_results(xpath_results)
          
          for_var = result_context.variables[clause.variable_name]
          if(for_var != nil)
            raise QueryStringError, "Reassigning value to a variable (#{clause.variable_name}) is not allowed in XQuery."
          end
          
          result_context.variables[clause.variable_name] = xpath_results
          
          
        when Expression::LET
          if(state >= STATE_LET)
            raise QueryStringError, "FLWOR not organized well"
          end
          raise StandardError, "to be implemented (clause LET)"
          
          
        when Expression::WHERE
          if(state >= STATE_WHERE)
            raise QueryStringError, "FLWOR not organized well"
          end
          
          #iterate over xpath_results from FOR clause and filter new results into result_context
          
          
          
        end
      }
      
      #TODO
      raise StandardError, "to be implemented"
    end
    
  end
end