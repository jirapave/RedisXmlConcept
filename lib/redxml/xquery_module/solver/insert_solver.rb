require_relative "../processor/insert_processor"

module XQuery
  class InsertSolver
    
    def initialize(path_solver)
      @path_solver = path_solver
      @insert_processor = InsertProcessor.new(path_solver)
    end
    
    def solve(expression, contexts, pipelined)
      
      target_location_keys = nil
      
      location = expression.location
      target_location_key = nil
        
      #load all possible locations from all contexts and ensure that there is only one location
      location_keys = []
      #load all locations
      contexts.each { |context|
        case location.type
        when ExpressionModule::RelativePathExpr
          location_keys.concat(@path_solver.solve(location, context))
        when ExpressionModule::VarRef
          location_keys << context.variables[location.var_name]
        else
          raise NotSupportedError, expression.location.type
        end
        
      }
      #check if they are all identical
      if(!ensure_identical(location_keys))
        raise StandardError, "wrong number of target location nodes, it is #{target_location_keys.length}, should be 1"
      end
        
      #set location extended key
      target_location_key = location_keys[0]
        
      
      @insert_processor.insert_nodes(expression.items, target_location_key, expression.target, pipelined, contexts)
      
    end
    
    def ensure_identical(extended_keys)
      prev_key_str = nil
      extended_keys.each { |ext_key|
        if(!prev_key_str)
          prev_key_str = ext_key.key_str
        elsif(prev_key_str != ext_key.key_str)
          return false
        end
      }
      return true
    end
    
  end
end