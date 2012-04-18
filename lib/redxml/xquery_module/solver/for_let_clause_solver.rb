module XQuery
  class ForLetClauseSolver
    
    
    #TODO check if it is working
    
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(clause_expr, context)
      # puts "solving #{clause_expr.type}"
      
      #LET clause
      if(clause_expr.type == ExpressionModule::LetClause)
        clause_expr.parts.each { |part|
          context.cycles.each { |cycle|
            cycle.variables[part.var_name] = @path_solver.solve(part.path_expr, cycle)
          }
        }
        return
      end
      
      
      #FOR clause
      
      #clone parts
      clause_parts = clause_expr.parts.clone
      
      clause_parts.reverse!
      first_part = clause_parts.pop
      solve_part(first_part, clause_parts, context)
    end
    
    def solve_part(clause_part, rest_parts, context)#returns new hash with new var and values (hierarchically child of incomming context)
      # puts "solving part"
      context.cycles.each { |cycle|
        # puts "solving part cycle"
        path_results = @path_solver.solve(clause_part.path_expr, cycle)
        cycle.populate(clause_part.var_name, path_results)
        
        if(!rest_parts.empty?)
          next_part = rest_parts.pop
          solve_part(next_part, rest_parts, cycle)
        end
      }
    end
    
  end
end