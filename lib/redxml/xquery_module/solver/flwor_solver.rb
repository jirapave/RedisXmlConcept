require_relative "path_solver"
require_relative "for_let_clause_solver"
require_relative "where_clause_solver"
require_relative "order_clause_solver"
require_relative "return_expr_solver"
require_relative "xquery_solver_context"
require_relative "../expression/expression_module"

module XQuery
  class FLWORSolver
    
    def initialize(path_solver, update_solver)
      @path_solver = path_solver
      @for_let_clause_solver = ForLetClauseSolver.new(@path_solver)
      @where_clause_solver = WhereClauseSolver.new(@path_solver)
      @order_clause_solver = OrderClauseSolver.new(@path_solver)
      @return_expr_solver = ReturnExprSolver.new(@path_solver, update_solver)
    end
    
    def solve(expression)

      @contexts = [ XQuerySolverContext.new ]
      @results = nil
      
      #iterate over all expression parts sequentially
      expression.parts.each { |part|
        process_flwor_part(part)
      }
      
      return @results
    end
    
    def process_flwor_part(part)
      
      case part.type
      when ExpressionModule::ForClause, ExpressionModule::LetClause
        @contexts.each { |context|
          @for_let_clause_solver.solve(part, context)
        }
        puts "before flatten: #{@contexts.inspect}"
        flatten_contexts()
        puts "after for/let flattening - context count: #{@contexts.length}"
        @contexts.each { |context|
          puts "final: #{context.final}, inspect: #{context.variables.inspect}"
        }
      when ExpressionModule::WhereClause
        new_contexts = []
        @contexts.each { |context|
          @where_clause_solver.solve(part, context)
          if(context.passed)
            new_contexts << context
          end
        }
        puts "after where context length: #{new_contexts.length}"
        @contexts = new_contexts
      when ExpressionModule::OrderByClause
        @order_clause_solver.solve(part, @contexts)
      when ExpressionModule::ReturnExpr
        @results = @return_expr_solver.solve(part, @contexts)
      else
        raise StandardError, "not possible flwor part type: #{part.type}"
      end
      
    end
    
    
    
    def flatten_contexts(context=nil)
      if(context == nil)
        ctxs = @contexts
        @contexts = []
        ctxs.each { |ctx|
          if(ctx.final)
            @contexts << ctx
          else
            @contexts.concat(flatten_contexts(ctx))
          end
        }
        puts "flatten return context count: #{@contexts.length}"
        return
      end
      
      ctxs = []
      context.cycles.each { |ctx|
        if(ctx.final)
          ctxs << ctx
        else
          ctxs << flatten_contexts(ctx)
        end
      }
      return ctxs
    end
    
    
  end
end