module XQuery
  class XQuerySolverContext
    
    attr_reader :variables, :final
    attr_accessor :passed, :order#, :last_var_name
    
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
        @variables[var_name] = content
        new_context = XQuerySolverContext.new(@variables)
        new_context.last_var_name = var_name
        @cycles << new_context
      }
      @variables = nil
      @final = false
    end
    
  end
end