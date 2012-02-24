module XQuery
  class FLWORContext
    
    attr_accessor :variables, :for_variable_name, :let_variable_name
    
    def initialize
      @variables = Hash.new
      @for_variable_name = nil
      @let_variable_name = nil
    end
    
  end
end