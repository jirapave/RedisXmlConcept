module Transformer
  #Raised every time there is a prolem with mapping, for example name cannot be mapped to id
  #or id cannot be found to be mapped back to name
  class MappingException < StandardError
  end
  
  #Raised by KeyElementBuilder when you try to build wrong/unacceptable key, for example
  #when you have only root key and call parent method, root has no parent > exception
  class NoElementError < StandardError
  end
  
  #Raised by KeyElementBuilder when you try to get prev_elem but there is none or when you try to get
  #previous order of text or order byt itself. Indexes currently begin on 1 so it is not possible to 
  #get previous element from key 1:2>1, because there isn't any. 
  class WrongOrderError < StandardError
  end
end