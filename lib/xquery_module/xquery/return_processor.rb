require_relative "../expression"
require_relative "../exceptions"

module XQuery
  class ReturnProcessor
    
    def initialize(xpath_controller)
      @xpath_controller = xpath_controller
    end
    
    def get_results(expression, flwor_context)
      results = []
      
      main_values = flwor_context.main_values
      main_values.each { |main_value|
        variables = Hash.new
        variables[flwor_context.main_variable_name] = [main_value]
        
        result = ""
        
        expression.parts.each { |part|
          case part.type
          when Expression::BASIC
            result << part.parts[0]
            
          when Expression::XPATH
            #TODO find out: this should return only one value, right?
            values = @xpath_controller.get_results(part, variables)
            if(values.length != 1)
              raise QueryStringError, "xpath in return processor under one main value should return 1 value, not #{values.length}"
            end
            result << values[0].to_stripped_s #TODO stripped?
            
          else
            raise QueryStringError, "in RETURN clause should be only xpath and basic expressions (I think)"
            
          end
        }
        
        results << result
      }
      
      return results
    end
    
    
  end
end