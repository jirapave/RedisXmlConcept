require_relative "../xml/text_content"
require_relative "key_builder"
require_relative "exceptions"

module Transformer
  class KeyElementBuilder
    
    SEPARATOR = ":"
    ITERATOR_KEY = "<iterator>"
    
    attr_reader :root_key
    
    MIN_ORDER = 1

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
    
    def comment(order)#:String
      "#{@root_key}#{@elem_str}>c>#{order}"
    end
    
    def cdata(order)#:String
      "#{@root_key}#{@elem_str}>d>#{order}"
    end
    
    def parent!()#:KeyElementBuilder
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no parent element for root element."
      else
        last_separator = @elem_str.rindex(SEPARATOR)
        @elem_str = @elem_str.slice(0, last_separator);
        return self
      end
    end
    
    def parent()#:String
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no parent element for root element."
      else
        last_separator = @elem_str.rindex(SEPARATOR)
        return "#{@root_key}#{@elem_str.slice(0, last_separator)}"
      end
    end
    
    def next_elem()#:String
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice((last_gt+1)..-1).to_i + 1;
        return "#{@root_key}#{@elem_str.slice(0, last_gt+1)}#{order}"
      end
    end
    
    def next_elem!()#:KeyElementBuilder
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        #Slice from last_gt+1 till the end [-1] using range object
        order = @elem_str.slice((last_gt+1)..-1).to_i + 1;
        @elem_str = "#{@elem_str.slice(0, last_gt+1)}#{order}";
        return self
      end
    end
    
    def prev_elem()#:String
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice((last_gt+1)..-1).to_i;
        if(order <= MIN_ORDER)
          raise WrongOrderError, "Cannot decrease order. Order is already #{MIN_ORDER}."
        end
        order -= 1
        return "#{@root_key}#{@elem_str.slice(0, last_gt+1)}#{order}"
      end
    end
    
    def prev_elem!()#:KeyElementBuilder
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice((last_gt+1)..-1).to_i;
        if(order <= MIN_ORDER)
          raise WrongOrderError, "Cannot decrease order. Order is already #{MIN_ORDER}."
        end
        order -= 1
        @elem_str = "#{@elem_str.slice(0, last_gt+1)}#{order}";
        return self
      end
    end
    
    def root_only?()
      @elem_str.empty?
    end
    
    def elem_id()#:String
      if(@elem_str.empty?)
        return @root_key
      else
        dd_split = @elem_str.split(SEPARATOR)
        return dd_split[dd_split.length-1].split('>')[0]
      end
      
    end
    
    def order()#:Integer
      if(@elem_str.empty?)
        raise WrongOrderError, "Cannot return order of the root element."
      else
        gt_split = @elem_str.split('>')
        return gt_split[gt_split.length-1].to_i 
      end
    end
    
    def self.text_order(key_str)#:Integer
      gt_split = self.last_dd_gt_split(key_str)
      if(gt_split == nil)
        raise WrongOrderError, "No text order to return."
      end
      if(gt_split.length < 3)
        raise WrongOrderError, "No text order to return."
      end
      if(!gt_split[gt_split.length-2] == "t")
        raise WrongOrderError, "No text order to return."
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
    
    def self.text_type?(key_str, type)
      type_char = ""
      case type
          when XML::TextContent::PLAIN
            type_char = "t"
          when XML::TextContent::COMMENT
            type_char = "c"
          when XML::TextContent::CDATA
            type_char = "d"
          else
            return false
        end
      gt_split = self.last_dd_gt_split(key_str)
      if(gt_split == nil)
        return false
      end
      if(gt_split.length < 3)
        return false
      end
      return gt_split[-2] == type_char
    end
    
    public
    def self.text?(key_str)
      self.text_type?(key_str, XML::TextContent::PLAIN)
    end
    
    def self.comment?(key_str)
      self.text_type?(key_str, XML::TextContent::COMMENT)
    end
    
    def self.cdata?(key_str)
      self.text_type?(key_str, XML::TextContent::CDATA)
    end  
    
    def self.element?(key_str)
      gt_split = self.last_dd_gt_split(key_str)
      if(gt_split.length < 3 or gt_split == nil)
        return true
      else
        return false
      end
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
          #Does not support text keys, e.g. 1:2>2>t>3 is translated to 1:2>2
          if(splitted_split.length < 2)
            break
          else
            instance.elem!(splitted_split[0], splitted_split[1].to_i)
          end
        }
      end
      
      return instance
    end
    
    def key_str()
      return "#{@root_key}#{@elem_str}"
    end
    
    def to_s()#:String
      return key_str()
    end
    
  end
  
end