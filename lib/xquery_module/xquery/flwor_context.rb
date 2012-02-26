module XQuery
  class FLWORContext
    
    attr_reader :variables, :main_variable_name, :let_variable_name
    attr_accessor :results
    
    def initialize
      @variables = Hash.new
      @main_variable_name = nil
      @let_variable_name = nil
      @results = nil
    end
    
    def set_main_variable(name, value)
      @main_variable_name = name
      @variables[name] = value
    end
    
    def set_let_variable(name, value)
      @let_variable_name = name
      @variables[name] = value
    end
    
    def main_values
      return @variables[@main_variable_name]
    end
    
    def main_values=(values)
      @variables[@main_variable_name] = values 
    end
    
    def let_values
      return @variables[@let_variable_name]
    end
    
  end
end