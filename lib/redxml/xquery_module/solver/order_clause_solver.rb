module XQuery
  class OrderClauseSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(order_expr, contexts)
      
      #support for one order so far TODO support for more
      if(order_expr.parts.length > 1)
        raise StandardError, "more then one order part not supported yet: #{order_expr.parts.length}"
      end

      
      modifier = order_expr.parts[0].modifier
      ordering_expr = order_expr.parts[0].expr


      original_results_order = Hash.new
      ordering_results = []
      contexts.each_with_index { |context, index|
        
        #retrieve results for ordering
        result = nil
        case ordering_expr.type
        when ExpressionModule::RelativePathExpr
          result = @path_solver.solve(ordering_expr, context)[0] # should be the same count
        when ExpressionModule::VarRef
          result = context.variables[ordering_expr.var_name] # should be the same count
        else
          raise NotSupportedError, ordering_expr.type
        end
        result_str = @path_solver.path_processor.get_text(result)
        original_results_order[result_str] = index
        ordering_results << result_str
        
      }
      
      
      #sort
      case modifier
      when "", "ascending" #classic
        ordering_results.sort!
      when "descending"
        ordering_results.sort!.reverse!
      else
        raise StandardError, "another sorting modifier not supported: #{modifier}"
      end
      
      
      ordering_results.each_with_index { |sorted_result, index|
        contexts[original_results_order[sorted_result]].order = index
      }
      
      
    end
    
  end
end