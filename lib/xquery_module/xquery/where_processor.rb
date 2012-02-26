require_relative "../expression"
require_relative "../exceptions"
require_relative "../sequence"

module XQuery
  class WhereProcessor
    
    def initialize(xpath_controller)
      @xpath_controller = xpath_controller
    end
    
    #this method will filter present variable values and store them ...hm TODO TODO
    def filter(expression, flwor_context) #where expression.parts has to contain some expressions
      
      #iterate over for values
      #and create function on each iteration...
      filtered_values = []
      
      # for_values = @xpath_controller.get_results(part, flwor_context.variables)
      for_values = flwor_context.main_values
      for_values.each { |for_value|
        variables = Hash.new
        variables[flwor_context.main_variable_name] = [for_value]
        #TODO deal with LET here entirely or elsewhere but different way
        #maybe in flwor_context somehow
        
      
        last_val = nil
        operator = nil
        
        expression.parts.each { |part|
          case part.type
            
          when Expression::XPATH
            value = Sequence.new(@xpath_controller.get_results(part, variables))
            
            #DEBUG TODO delete
            puts "WHERE PROCESSOR xpath: #{value.inspect}"
            
            if(last_val == nil)
              last_val = value
            else
              allowed = BinaryOperator.evaluate(operator, last_val, value)
              filtered_values << for_value if(allowed)
            end
            
            
          when Expression::VARIABLE
            value = Sequence.new(variables.variables[part.name])
            
            #DEBUG TODO delete
            puts "WHERE PROCESSOR var: #{value.inspect}"
            
            if(last_val == nil)
              last_val = value
            else
              allowed = BinaryOperator.evaluate(operator, last_val, value)
              filtered_values << for_value if(allowed)
            end
            
            
          when Expression::ATOMIC_VALUE
            value = part.parts[0]
            
            #DEBUG TODO delete
            puts "WHERE PROCESSOR atomic: #{value.inspect}"
            
            if(last_val == nil)
              last_val = value
            else
              allowed = BinaryOperator.evaluate(operator, last_val, value)
              filtered_values << for_value if(allowed)
            end
            
            
          when Expression::BINARY_OPERATOR
            operator = part.name
            
            #DEBUG TODO delete
            puts "WHERE PROCESSOR operator: #{operator}"
            
            
          else
            raise StandardError, "another type of expression (#{part.type}) not implemented in WhereProcessor"
            
          end
        }  
      }
      
      #TODO support more complex where clauses

      #DEBUG TODO delete
      puts "WHERE PROCESSOR filtered: #{filtered_values.inspect}"
      
      flwor_context.main_values = filtered_values
    end
    
  end
end