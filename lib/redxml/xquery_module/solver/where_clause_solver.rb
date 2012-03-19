require_relative "../expression/expression_module"
require_relative "../expression/dummy_expression_handle"

module XQuery
  class WhereClauseSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
    end
    
    def solve(where_expr, context)
      puts "solving #{where_expr.type}"
      
      specific_where_expr = where_expr.value 
      case specific_where_expr.type
      when ExpressionModule::ComparisonExpr
        values1 = get_comparison_values(specific_where_expr.value1, context)
        operator = specific_where_expr.operator
        values2 = get_comparison_values(specific_where_expr.value2, context)
        result = ComparisonSolver.evaluate(values1, operator, values2)
        context.passed = result
        
      else
        raise StandardError, "no other where clause solving implmenented: #{where_expr.value.type}"
      end
    end
    
    
    
    
    def get_comparison_values(expression, context)
      case expression.type
      when ExpressionModule::RelativePathExpr
        results = @path_solver.solve(expression, context)
        final_values = []
        results.each { |result|
          final_result = result
          if(result.kind_of?(ExtendedKey))
            final_result = @path_solver.path_processor.get_node_content(result)
          end
          final_values << ExpressionModule::DummyExpressionHandle.new(ExpressionModule::StringLiteral, final_result)
        }
        return final_values
        
      #String and Numeric literals return as are - literal objects, so it is recognisable the type
      when ExpressionModule::NumericLiteral
        #returning numeric
        return [ expression ]
         
      when ExpressionModule::StringLiteral
        #returning string
        return [ ExpressionModule::DummyExpressionHandle.new(ExpressionModule::StringLiteral, expression.text.gsub("'", "").gsub('"', "")) ]
         
      else
        raise StandardError, "other types of predicate values are not supported yet: #{expression.type}"
        
      end
    end
    
    
    
    
  end
end