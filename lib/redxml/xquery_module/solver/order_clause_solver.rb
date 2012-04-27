module XQuery
  class OrderClauseSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(order_expr, contexts)
      
      #support for one order so far TODO support for more
      if(order_expr.parts.length > 1)
        raise NotSupportedError, "more then one order part not supported yet: #{order_expr.parts.length}"
      end

      
      modifier = order_expr.parts[0].modifier
      ordering_expr = order_expr.parts[0].expr


      original_results_order = Hash.new
      ordering_results = []
      puts "context length: #{contexts.length}"
      contexts.each_with_index { |context, index|
        
        #retrieve results for ordering
        results = nil
        case ordering_expr.type
        when ExpressionModule::RelativePathExpr
          results = @path_solver.solve(ordering_expr, context)
        when ExpressionModule::VarRef
          results = context.variables[ordering_expr.var_name]
        else
          raise NotSupportedError, ordering_expr.type
        end
        
        #retrieve text content from results and join that
        result_str = ""
        results.each { |result|
          result_str << @path_solver.path_processor.get_text(result)
        }
        
        #some results could be the same
        result_str << " <#{index}"
        
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