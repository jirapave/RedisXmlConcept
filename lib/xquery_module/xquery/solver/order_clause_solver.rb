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


      # original_order_hash = Hash.new
      original_results_order = Hash.new
      ordering_results = []
      contexts.each_with_index { |context, index|
        #save current order
        # original_order_hash[context.last_var_name] = index
        
        #retrieve results for ordering
        result = @path_solver.solve(ordering_expr, context)[0] # should be the same count
        result_str = result.to_s
        original_results_order[result_str] = index
        ordering_results << result_str
        
      }
      
      
      
      #sort
      ordering_results.sort.each_with_index { |sorted_result, index|
        contexts[index].order = original_results_order[sorted_result]
      }
      
      
    end
    
  end
end