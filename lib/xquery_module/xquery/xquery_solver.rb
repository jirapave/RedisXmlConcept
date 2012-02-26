require_relative "../xpath/xpath_controller"
require_relative "../expression"
require_relative "flwor_context"
require_relative "flwor_controller"

module XQuery
  class XQuerySolver
    def initialize(environment, collection)
      @xpath_controller = XPathController.new(environment, collection)
      @flwor_controller = FLWORController.new(@xpath_controller)
    end
    
    def get_results(expression)
      #reduce groups in expression
      expression = reduce_groups(expression)
      
      #structure the expression even better (FOR clause contains it's values etc.)
      expression = structure_expression(expression)
      
      #remember root expression
      root_expression = expression
      
      #DEBUG TODO delete
      puts "-=WALK=-"
      root_expression.walkthrough
      
      return solve_query(root_expression)
      
      
      #TODO resolve each xpath sequentially into sequences of nodes/data
      # store each resolved xpath sequences of results into the structured expression
      #TODO TIP: XPATH Predicate should be always solved after this step is resolved normally on lazy load
      
      #TODO resolve sequentially FLWOR - that is rest of variables, than other stuff
      # and we have final sequence of nodes/data - return it
    end

  private
  
    #main SOLVER method
    def solve_query(expression)
      if(expression.type == Expression::GROUP && !expression.parts.empty? && expression.parts[0].type == Expression::FOR)
        return @flwor_controller.get_results(expression)
      
      elsif(expression.type == Expression::XPATH)
        return @xpath_controller.get_results(expression)
      
      else
        raise StandardError, "another type of query not supported - has to be basic FLWOR or XPATH"        
        
      end
    end
  
  
    def structure_expression(expression)
      #scan expression for FLWOR (FOR, LET, WHERE, ORDER_BY and RETURN clauses)
      #these clauses will be parents of their following siblings
      actual_clause = nil
      
      #FOR clause flags
      for_iter_count = 0
      
      del_expressions = [] #expressions which has to be removed from this expression.parts
      
      expression.parts.each { |part|
        case part.type
        when Expression::FOR, Expression::LET, Expression::WHERE, Expression::ORDER_BY, Expression::RETURN 
          actual_clause = part
          
        else
          if(actual_clause != nil)
            del_expressions << part
            part.parent = actual_clause unless(actual_clause == nil)
            
            case actual_clause.type
            when Expression::FOR
              for_iter_count += 1
              if(for_iter_count == 1 && part.type == Expression::VARIABLE)
                actual_clause.variable_name = part.name
              elsif(for_iter_count == 2 && !part.parts.empty? && part.parts[0] == "in")
                # just validating query
              elsif(for_iter_count >= 3 && (part.type == Expression::XPATH || part.type == Expression::VARIABLE))
                actual_clause.value << part
              else
                raise QueryStringError, "wrongly structured FOR clause"
              end
              
            when Expression::LET
              raise StandardError, "to be implemented"
              
            when Expression::WHERE
              actual_clause.parts << part
              
            when Expression::ORDER_BY
              if(part.type == Expression::XPATH || part.type == Expression::VARIABLE)
                actual_clause.value << part
              else
                raise QueryStringError, "wrong type of expression under ORDER_BY clause: #{part.type}"
              end
              
            when Expression::RETURN
              actual_clause.parts << part
              
            else
              raise StandardError, "impossible: another clause type #{actual_clause.type}"
              
            end
          end
        end
      }
      
      del_expressions.each { |del| expression.parts.delete(del) }
      
      return expression
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
      
      if(expression.kind_of?(Expression) && expression.parts.kind_of?(Array) && !expression.parts.empty?)
        expression.parts.each { |part|
          if(part.kind_of?(Expression))
            reduce_groups(part)
          end
        }
      end
      
      return expression
      
    end
    
  end
end