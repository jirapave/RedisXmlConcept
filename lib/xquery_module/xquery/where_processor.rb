module XQuery
  class WhereProcessor
    
    def initialize(xpath_controller)
      @xpath_controller = xpath_controller
    end
    
    #this method will filter present variable values and store them ...hm TODO TODO
    def self.filter(expression, result_context) #where expression.parts has to contain some expressions
      last_val = nil
      operator = nil
      
      expression.parts.each { |part|
        case part.type
          
        when Expression::XPATH
          if(last_val == nil)
            last_val = @xpath_controller.get_results(part)
            puts "WHERE PROCESSOR xpath: #{last_val.inspect}"
          else
            
          end
          
          
        when Expression::VARIABLE
          
          
          
          
        end
      }
    end
    
  end
end