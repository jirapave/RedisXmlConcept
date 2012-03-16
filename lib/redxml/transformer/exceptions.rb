module Transformer
  # Raised every time there is a prolem with mapping, for example name cannot be mapped to id
  # or id cannot be found to be mapped back to name
  class MappingException < StandardError
  end
  
  # Raised when you try to build wrong/unacceptable key, for example when you have only root key 
  # and calls KeyElementBuilder#parent method, root has no parent > exception
  class NoElementError < StandardError
  end
  
  # Raised when you try to get element which cannot exist = has order lower than 0. This could happen
  # when you try to get previous order of text with KeyElementuilder#prev_elem method or when used with
  # root element.
  class WrongOrderError < StandardError
  end
  
  #Raised when next* method is called on some iterator and there are no more items to iterate over
  class NoIteratorNext < StandardError
  end
end