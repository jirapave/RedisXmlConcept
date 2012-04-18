require_relative "path_solver"
require_relative "for_let_clause_solver"
require_relative "where_clause_solver"
require_relative "order_clause_solver"
require_relative "return_expr_solver"
require_relative "../processor/delete_processor"
require_relative "xquery_solver_context"
require_relative "../expression/expression_module"

module XQuery
  class DeleteSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(expression, contexts, pipelined=true)
      
      location = expression.location
      
      nodes_to_delete = []
      
      contexts.each { |context|
        case location.type
        when ExpressionModule::RelativePathExpr
          nodes_to_delete.concat(@path_solver.solve(expression.location, context))
        when ExpressionModule::VarRef
          nodes_to_delete.concat(context.variables[location.var_name])
        else
          raise NotSupportedError, expression.location.type
        end
      }
      
      DeleteProcessor.delete_nodes(nodes_to_delete, pipelined)
      
      
    end
  end
end