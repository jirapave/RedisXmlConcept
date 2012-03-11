module XQuery
  class ReturnExprSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(return_expr, contexts)
      
      results = []
      
      sorting_hash = Hash.new
      contexts.each_with_index { |contex, index|
        sorting_hash[context.order] = index
      }
      sorting_hash.keys.sort.each { |sort_key|
        context = contexts[sorting_hash[sort_key]]
        results.concat(@path_solver.solve(return_expr.value, context))
      }
       
      return results      
    end
    
  end
end