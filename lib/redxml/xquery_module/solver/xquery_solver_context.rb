module XQuery
  class XQuerySolverContext
    
    attr_reader :final
    attr_accessor :passed, :order, :variables
    
    def initialize(variables=Hash.new)
      @variables = variables #in hash can be KeyElementBuilders or prepared Nodes
      @cycles = [] #cycles contain another solver contexts
      @final = true
      @passed = true
      @order = -1
      # @last_var_name = nil
    end
    
    def cycles
      if(@cycles.empty?)
        return [ self ]
      else
        return @cycles
      end
    end
    
    def populate(var_name, var_contents)
      var_contents.each { |content|
        @new_variables = @variables.clone
        @new_variables[var_name] = [ content ]
        new_context = XQuerySolverContext.new(@new_variables)
        @cycles << new_context
      }
      @variables = nil
      @final = false
    end
    
  end
end