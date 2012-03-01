require_relative "../expression"
require_relative "../exceptions"
require_relative "../xpath/node_xpath_processor"

module XQuery
  class OrderProcessor
    
    def initialize(xpath_controller)
      @xpath_controller = xpath_controller
      @node_xpath_processor = NodeXPathProcessor.new
    end
    
    def order(expression, flwor_context)
      
      main_values = flwor_context.main_values
      values_to_sort = []
      expression.value.each { |val|
        case val.type
        when Expression::XPATH
          xpath_values = @xpath_controller.get_results(val, flwor_context.variables)
          xpath_values.each_with_index { |xpath_value, index|
            xpath_values[index] = @node_xpath_processor.get_node_content(xpath_value)
          }
          values_to_sort.concat(xpath_values)
        when Expression::VARIABLE
          values_to_sort << flwor_context.variables[val.name]
        else
          raise StandardError, "another expression (#{part.type}) not implemented in OrderProcessor"
        end
      }
      
      #DEBUG TODO delete
      puts "ORDER_BY values to sort"
      puts values_to_sort.inspect
      
      
      #sort values, remember indexes of main variable values and values
      #and the result should be sorted values of main variable values (not the actual sorted ones)
      #then save it into flwor_context - main variable
      
      if(main_values.length != values_to_sort.length)
        raise StandardError, "main values produced in ORDER_BY clause more then one value each - unsupported by this code - TODO look at XQuery speicification"
      end
      
      mem_hash = Hash.new
      values_to_sort.each_with_index { |val, index|
        mem_hash[val] = index
      }
      values_to_sort.sort!
      main_values_to_store = []
      values_to_sort.each { |val|
        main_values_to_store << main_values[mem_hash[val]]
      }
      
      flwor_context.main_values = main_values_to_store #TODO check if it is working
      
      #DEBUG TODO delete
      puts "ORDERED_DEBUG"
      puts flwor_context.main_values.inspect
      
      
    end
    
  end
end