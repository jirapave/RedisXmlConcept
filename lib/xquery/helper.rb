module XQuery
  class Helper
    
    def self.is_number?(value)
      value.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end
    
    def self.make_number(value)
      begin
        Float(value)
      rescue
        nil
      end
    end
    
    def self.is_boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass) 
    end
    
  end
end