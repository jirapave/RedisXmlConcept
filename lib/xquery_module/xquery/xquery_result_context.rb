module XQuery
  class XQueryResultContext
    
    #STATES
    # INITIAL = :initial
    # XPATH_ONLY = :xpath_only
    # FOR = :for
    # LET = :let
    # WHERE = :where
    # ORDER_BY = :order_by
    # RETURN = :return
    
    
    def initialize
      @variables = Hash.new
      @filtered_results = []
      # @xpath = [] # list of nodes or data
      # @state = INITIAL
      #TODO on the run
    end
    
    attr_accessor :variables, :filtered_results#, :xpath, :state
  end
end