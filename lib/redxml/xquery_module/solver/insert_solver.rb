require_relative "../processor/insert_processor"

module XQuery
  class InsertSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
      @insert_processor = InsertProcessor.new(path_solver)
    end
    
    def solve(expression, context, pipelined)
      
      target_location_keys = nil
      
      location = expression.location
      case location.type
      when ExpressionModule::RelativePathExpr
        target_location_keys = @path_solver.solve(location, context)
        
      when ExpressionModule::VarRef
        target_location_keys = [ context.variables[location.var_name] ]
        
      else
        raise NotSupportedError, expression.location.type 
      end
      
      if(target_location_keys.length != 1)
        raise StandardError, "wrong number of target location nodes, it is #{target_location_keys.length}, should be 1"
      end
      
      @insert_processor.insert_nodes(expression.items, target_location_keys[0], expression.target, pipelined, context)
      
    end
    
  end
end