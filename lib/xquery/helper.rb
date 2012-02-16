module XQuery
  class Helper
    
    def self.is_number(value)
      value.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
    end
    
    def self.make_number(value)
      begin
        Float(value)
      rescue
        nil
      end
    end
    
  end
end