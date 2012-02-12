module XQuery
  class XQueryResultContext
    
    #STATES
    INITIAL = :initial
    XPATH_ONLY = :xpath_only
    FOR = :for
    LET = :let
    WHERE = :where
    ORDER_BY = :order_by
    RETURN = :return
    
    
    def initialize
      @variables = Hash.new
      @xpath = [] # list of nodes or data
      @state = INITIAL
      #TODO on the run
    end
    
    attr_accessor :variables, :xpath, :state
  end
end