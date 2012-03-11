module XQuery
  class ForLetClauseSolver
    
    
    #TODO check if it is working
    
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(clause_expr, context)
      clause_expr.parts.reverse!
      first_part = clause_expr.parts.pop
      solve_part(first_part, clause_expr.parts, context)
    end
    
    def solve_part(clause_part, rest_parts, context)#returns new hash with new var and values (hierarchically child of incomming context)
      context.cycles { |cycle|
        path_results = @path_solver.solve(clause_part.path_expr, cycle)
        path_results.each { |result|
          cycle.add_cycle(clause_part.var_name, result)
        }
        
        if(!rest_parts.empty?)
          next_part = rest_parts.pop
          solve_part(next_part, rest_parts, cycle)
        end
      }
    end
    
  end
end