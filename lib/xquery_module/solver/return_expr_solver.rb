module XQuery
  class ReturnExprSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(return_expr, contexts)
      puts "solving #{return_expr.type}"
      
      results = []
      
      sorting_hash = Hash.new
      contexts.each_with_index { |context, index|
        sorting_hash[context.order] = index
      }
      sorting_hash.keys.sort.each { |sort_key|
        
        context = contexts[sorting_hash[sort_key]]
        puts "RETURNING according order: #{context.order}"
        results.concat(@path_solver.solve(return_expr.value, context))
      }
       
      return results      
    end
    
  end
end