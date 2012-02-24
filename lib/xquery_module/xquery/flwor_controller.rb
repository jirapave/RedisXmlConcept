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
    
    def get_results(expression)
      state = 0
      flwor_context = FLWORContext.new
      
      expression.parts.each { |clause|
        case clause.type
          
        when Expression::FOR
          check_state(state, STATE_FOR)
          
          #we have most likely xpath query in value attribute of FOR clause
          #solve this query, store it to variable (into the result_context object)
          xpath_results = @xpath_controller.get_results(clause.value, flwor_context)
          
          #DEBUG TODO delete
          Helper.print_results(xpath_results)
          
          for_var = flwor_context.variables[clause.variable_name]
          if(for_var != nil)
            raise QueryStringError, "Reassigning value to a variable (#{clause.variable_name}) is not allowed in XQuery."
          end
          
          flwor_context.variables[clause.variable_name] = xpath_results
          flwor_context.for_variable_name = clause.variable_name
          
          
        when Expression::LET
          check_state(state, STATE_LET)
          #TODO 
          raise StandardError, "to be implemented (clause LET)"
          
          
        when Expression::WHERE
          check_state(state, STATE_WHERE)
          
          #TODO create a filtering function (somehow) - figure out!! TODO TODO
          
          #iterate over for variable values and apply this function -> filter values from for variable values and store those values
          # to filtered values - store to flwor_context
          
          
        when Expression::ORDER_BY
          check_state(state, STATE_ORDER_BY)
          
          #TODO iterate over where variable values, create by xpath each and sort out these where values
          # store to ordered values - to flwor_context
          
          
        when Expression::RETURN
          check_state(state, STATE_RETURN)
          
          #TODO iterate over last stored values from flwor context and create return values
          
        end
      }
      
      #TODO
      raise StandardError, "to be implemented"
    end
    
  private
    def check_state(last_state, actual_state)
      if(last_state >= actual_state)
        raise QueryStringError, "FLWOR not organized well"
      end
    end
    
  end
end