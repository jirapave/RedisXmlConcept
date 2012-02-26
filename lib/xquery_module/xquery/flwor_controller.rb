require_relative "../expression"
require_relative "../exceptions"
require_relative "../helper"
require_relative "flwor_context"
require_relative "where_processor"
require_relative "order_processor"
require_relative "return_processor"

module XQuery
  class FLWORController #TODO check functionality
    
    STATE_FOR = 1
    STATE_LET = 2
    STATE_WHERE = 3
    STATE_ORDER_BY = 4
    STATE_RETURN = 5
    
    def initialize(xpath_controller)
      @xpath_controller = xpath_controller
      @where_processor = WhereProcessor.new(xpath_controller)
      @order_processor = OrderProcessor.new(xpath_controller)
      @return_processor = ReturnProcessor.new(xpath_controller)
    end
    
    def get_results(expression)
      results = []
      state = 0
      flwor_context = FLWORContext.new
      
      expression.parts.each { |clause|
        case clause.type
          
        when Expression::FOR
          check_state(state, STATE_FOR)
          
          #we have most likely xpath query (queries) in value Array attribute of FOR clause
          #solve this query, store it to variable (into the result_context object)
          xpath_results = []
          clause.value.each { |val|
            xpath_results.concat(@xpath_controller.get_results(val))
          }
          
          #DEBUG TODO delete
          puts "FOR results"
          Helper.print_results(xpath_results)
          
          for_var = flwor_context.variables[clause.variable_name]
          if(for_var != nil)
            raise QueryStringError, "Reassigning value to a variable (#{clause.variable_name}) is not allowed in XQuery."
          end
          
          flwor_context.set_main_variable(clause.variable_name, xpath_results)
          
          
        when Expression::LET
          check_state(state, STATE_LET)
          #TODO
          raise StandardError, "to be implemented (clause LET)"
          
          
        when Expression::WHERE
          check_state(state, STATE_WHERE)

          @where_processor.filter(clause, flwor_context)
          
          
        when Expression::ORDER_BY
          check_state(state, STATE_ORDER_BY)
          
          @order_processor.order(clause, flwor_context)
          
          
        when Expression::RETURN
          check_state(state, STATE_RETURN)
          
          results = @return_processor.get_results(clause, flwor_context)
          
          
        end
      }
      
      return results
    end
    
  private
    def check_state(last_state, actual_state)
      if(last_state >= actual_state)
        raise QueryStringError, "FLWOR not organized well"
      end
    end
    
  end
end