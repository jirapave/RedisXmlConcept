require_relative "xpath_controller"
require_relative "expression"
require_relative "xquery_result_context"

module XQuery
  class XQuerySolver
    def initialize(database, collection)
      @xpath_controller = XPathController.new(database, collection)
    end
    
    def get_results(expression)
      #clear previous results and create new one
      @result_context = XQueryResultContext.new
      
      #TODO structure the expression even better (for contains it's values etc.)
      root_expression = expression
      
      expression = reduce_groups(expression)
      
      puts "-=WALK=-"
      expression.walkthrough
      
      if(expression.type == Expression::XPATH)
        return @xpath_controller.get_results(expression, @result_context)
      else
        raise StandardError, "not yet implemented"
      end
      
      
      #TODO resolve each xpath sequentially into sequences of nodes/data
      # store each resolved xpath sequences of results into the structured expression
      #TODO TIP: XPATH Predicate should be always solved after this step is resolved normally on lazy load
      
      #TODO resolve sequentially FLWOR - that is rest of variables, than other stuff
      # and we have final sequence of nodes/data - return it
    end

  private
  
    def solve_query(expression)
      if(expression.type == Expression::GROUP)
        #TODO - this is not good at all
        expression.parts.each { |part|
          solve_query(part)
        }
        
      
      elsif(expression.type == Expression::XPATH)
        
        if(result_context.state == XQueryResultContext::INITIAL)
          result_context.state = XQueryResultContext::XPATH_ONLY
        end
        result_context.xpath = @xpath_controller.get_results(expression)
        
        
      end
    end
    
    
  
    # if there is GROUP with only one part -> reduce to the part
    def reduce_groups(expression)
      if(expression.type == Expression::GROUP)
        if(expression.parts.length == 1)
          parent = expression.parent
          child = expression.parts[0]
          if(parent != nil)
            expr_index = parent.parts.index(expression)
            parent.parts.insert(expr_index, child)
            parent.parts.delete(expression)
            child.parent = parent
          else
            child.parent = nil
          end
          expression = child
        elsif(expression.parts.length == 0)
          parent = expression.parent
          if(parent != nil)
            parent.parts.delete(expression)
          end
          expression = nil
        end
      end
      
      if(expression.respond_to(:parts) && expression.parts.respond_to?(each) && !expression.parts.empty?)
        expression.parts.each { |part|
          reduce_groups(part)
        }
      end
      
      return expression
      
    end
    
  end
end