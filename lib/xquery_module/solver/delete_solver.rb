require_relative "path_solver"
require_relative "for_let_clause_solver"
require_relative "where_clause_solver"
require_relative "order_clause_solver"
require_relative "return_expr_solver"
require_relative "xquery_solver_context"
require_relative "../expression/expression_module"

module XQuery
  class DeleteSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(expression)
      
      case expression.location.type
      when ExpressionModule::RelativePathExpr
        nodes_to_delete = @path_solver.solve(expression.location)
        
      else
        raise NotSupportedError, expression.location.type 
      end
      
      
    end
  end
end