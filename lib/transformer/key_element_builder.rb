require_relative "key_builder"

module Transformer
  class KeyElementBuilder
    
    SEPARATOR = ":"
    ITERATOR_KEY = "<iterator>"
    
    attr_reader :root_key

    def initialize(key_builder, root_id)
      @root_key = "#{root_id}"
      @elem_str = ""
    end
    
    def elem!(elem_id, order)#:KeyElementBuilder
      @elem_str += "#{SEPARATOR}#{elem_id}>#{order}"
      return self
    end
    
    def elem(elem_id, order)#:String
      "#{self.to_s}#{SEPARATOR}#{elem_id}>#{order}"
    end

    def attr()#:String
      "#{self.to_s}<a"
    end
    
    def text(order)#:String
      "#{@root_key}#{@elem_str}>t>#{order}"
    end
    
    def text_count()#:String
      "#{@root_key}#{@elem_str}>t<c"
    end
    
    def parent!()#:KeyElementBuilder
      if(@elem_str.empty?)
        raise NoElementError, "There is no parent element for root element."
      else
        last_separator = @elem_str.rindex(SEPARATOR)
        @elem_str = @elem_str.slice(0, last_separator);
        return self
      end
    end
    
    def parent()#:String
      if(@elem_str.empty?)
        raise NoElementError, "There is no parent element for root element."
      else
        last_separator = @elem_str.rindex(SEPARATOR)
        return "#{@root_key}#{@elem_str.slice(0, last_separator)}"
      end
    end
    
    def next_elem()#:String
      if(@elem_str.empty?)
        raise NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i + 1;
        return "#{@root_key}#{@elem_str.slice(0, last_gt+1)}#{order}"
      end
    end
    
    def next_elem!()#:KeyElementBuilder
      if(@elem_str.empty?)
        raise NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i + 1;
        @elem_str = "#{@elem_str.slice(0, last_gt+1)}#{order}";
        return self
      end
    end
    
    def prev_elem()#:String
      if(@elem_str.empty?)
        raise "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i;
        if(order <= 0)
          raise NegativeOrderError, "Cannot decrease order. Order is already 0."
        end
        order -= 1
        return "#{@root_key}#{@elem_str.slice(0, last_gt+1)}#{order}"
      end
    end
    
    def prev_elem!()#:KeyElementBuilder
      if(@elem_str.empty?)
        raise NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i;
        if(order <= 0)
          raise NegativeOrderError, "Cannot decrease order. Order is already 0."
        end
        order -= 1
        @elem_str = "#{@elem_str.slice(0, last_gt+1)}#{order}";
        return self
      end
    end
    
    def root_only?()
      @elem_str.empty?
    end
    
    def elem_name()#:String
      if(@elem_str.empty?)
        return @root_key
      else
        dd_split = @elem_str.split(SEPARATOR)
        return dd_split[dd_split.length-1].split('>')[0]
      end
      
    end
    
    def order()#:Integer
      if(@elem_str.empty?)
        return -1
      else
        gt_split = @elem_str.split('>')
        return gt_split[gt_split.length-1].to_i 
      end
    end
    
    def self.text_order(key_str)#:Integer
      gt_split = self.last_dd_gt_split(key_str)
      if(gt_split == nil)
        return -1
      end
      if(gt_split.length < 3)
        return -1
      end
      if(!gt_split[gt_split.length-2] == "t")
        return -1
      end
      return gt_split[gt_split.length-1].to_i 
    end
    
    private
    def self.last_dd_gt_split(key_str)#:Array
      dd_split = key_str.split(SEPARATOR)
      if(dd_split.length < 1)
        return nil
      end
      return dd_split[-1].split('>')
    end
    
    public
    def self.text?(key_str)
      gt_split = self.last_dd_gt_split(key_str)
      if(gt_split == nil)
        return false
      end
      if(gt_split.length < 3)
        return false
      end
      return gt_split[-2] == "t"
    end
          
    def self.build_from_s(key_builder, key_str)#:KeyElementBuilder
      key_split = key_str.split(SEPARATOR)
      if(key_split.length < 1)
        raise NotEnoughParametersError, "#{key_str} cannot be parsed."
      end
      
      root_id = key_split[0]
      
      instance = Transformer::KeyElementBuilder.new(key_builder, root_id)
      if key_split.length > 1
        (1..key_split.length-1).each { |index|
          splitted_split = key_split[index].split(">")
          if(splitted_split.length < 2)
            break
          end
          instance.elem!(splitted_split[0], splitted_split[1].to_i)
        }
      end
      
      return instance
    end
    
    def to_s()#:String
      "#{@root_key}#{@elem_str}"
    end
    
  end
  
  #exceptions
  class NoElementError < StandardError
  end
  
  class NegativeOrderError < StandardError
  end
  
end