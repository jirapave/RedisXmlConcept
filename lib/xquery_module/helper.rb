require_relative "../xml/node"

module XQuery
  class Helper
    
    def self.is_number?(value)
      value.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end
    
    def self.make_number(value)
      begin
        return Integer(value)
      rescue
        begin
          return Float(value)
        rescue
          return nil
        end
      end
    end
    
    def self.is_boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass) 
    end
    
    #prints nodes and strings, results has to be array
    def self.print_results(results)
      puts "RESULTS (#{results.length}):"
      results.each { |result|
        if(result.kind_of?(XML::Node))
          puts result.to_stripped_s
        else
          puts result
        end
        puts "----------"
      }
    end
    
  end
end