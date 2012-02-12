module XQuery
  class SpecifiedPredicate
    
    #between more predicates
    LOGIC_AND = :and
    LOGIC_OR = :or
    
  end
  
  class IndexPredicate < SpecifiedPredicate
    
    #will be added instead of last index
    AND_MORE = :and_more
    AND_LESS = :and_less
    
    def initialize(*indexes)
      @indexes = indexes
    end
    
    attr_accessor :indexes
    
  end
  
  class AttributePredicate < SpecifiedPredicate
    
    #attr_hash will contain attribute name as key and true/false if this attribute is allowed in result
    def initialize(attr_hash)
      @attributes = attr_hash
    end
    
    attr_accessor :attributes
    
  end
  
end