module XQuery
  class QueryStringError < StandardError
  end
  
  class TypeError < QueryStringError
  end
end