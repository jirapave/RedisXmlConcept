module XQuery
  class Sequence
    
    SEQUENCE = :sequence
    ATOMIC_VALUE = :atomic
    NODE = :node #the "xml/node" one
    
    def initialize(value=[], type=SEQUENCE)
      @value = value # array of sequences
      @type = type
    end
    
    attr_accessor :value, :type
  end
  
  class AtomicValue
    UNTYPED = :untyped
    STRING = :string  #String
    NUMERIC = :numeric #Fixnum, Float
    
    def initialize(value, type=UNTYPED)
      @value = value
      @type = type
    end
    attr_accessor :value, :type
  end
end