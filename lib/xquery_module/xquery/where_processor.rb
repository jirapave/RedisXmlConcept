module XQuery
  class WhereProcessor
    
    def initialize(xpath_controller)
      @xpath_controller = xpath_controller
      @db_helper = @xpath_controller.db_helper
    end
    
    def self.evaluate(expression) #where expression.parts has to contain some expressions
      expression.parts.each { |part|
        case part.type
          
        when Expression::XPATH
          
          
        end
      }
    end
    
  end
end