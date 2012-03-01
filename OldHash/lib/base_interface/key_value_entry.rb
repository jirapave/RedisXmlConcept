module BaseInterface
  class KeyValueEntry
    
    attr_reader :key
    attr_accessor :value
    
    def initialize(key)
      @key = key
      @value = nil
    end
    
  end
end