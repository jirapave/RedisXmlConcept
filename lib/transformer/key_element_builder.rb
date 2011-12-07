require_relative "key"

module Transformer
  class KeyElementBuilder < Transformer::Key
    
    private_class_method :new

    def initialize(db_name, col_name, doc_name, root_name)
      super(db_name, col_name, doc_name)
      @root_name = root_name
      @root_key = "#{@document_key}#{:"::"}#{root_name}"
      @elem_str = ""
    end
    
    def self.create(db_name, col_name, doc_name, root_name):KeyElementBuilder
      new(db_name, col_name, doc_name, root_name)
    end
    
    def elem!(elem_name, order):KeyElementBuilder
      @elem_str += "#{:"::"}#{elem_name}#{:">"}#{order}"
      return self
    end
    
    def elem(elem_name, order):String
      "#{self.to_s}#{:"::"}#{elem_name}#{:">"}#{order}"
    end

    def attr():String
      "#{self.to_s}#{:"<"}#{:"attributes"}"
    end
    
    def attr_order():String
      "#{self.to_s}#{:"<"}#{:"attributes"}#{:"<"}#{:"order"}"
    end
    
    def count():String
      if(@elem_str.empty?)
        puts "There is no element inserted, so cannot create ...<count key. (root element has no count key)"
        raise NoElementError
      else
        last_lt = @elem_str.rindex(">")
        return "#{@root_key}#{@elem_str.slice(0, last_lt)}#{:"<"}#{:"count"}"
      end
    end
    
    def text(order):String
      "#{@root_key}#{@elem_str}#{:">"}#{:"text"}#{:">"}#{order}"
    end
    
    def text_count():String
      "#{@root_key}#{@elem_str}#{:">"}#{:"text"}#{:"<"}#{:"count"}"
    end
    
    def parent!():KeyElementBuilder
      if(@elem_str.empty?)
        puts "There is no parent element for root element."
        raise NoElementError
      else
        last_double_dot = @elem_str.rindex("::")
        @elem_str = @elem_str.slice(0, last_double_dot);
        return self
      end
    end
    
    def parent():String
      if(@elem_str.empty?)
        puts "There is no parent element for root element."
        raise NoElementError
      else
        last_double_dot = @elem_str.rindex("::")
        return "#{@root_key}#{@elem_str.slice(0, last_double_dot)}"
      end
    end
    
    def next_elem():String
      if(@elem_str.empty?)
        puts "There is no child element of root. Cannot call next_elem, while root is always only one."
        raise NoElementError
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i + 1;
        return "#{@root_key}#{@elem_str.slice(0, last_gt+1)}#{order}"
      end
    end
    
    def next_elem!():KeyElementBuilder
      if(@elem_str.empty?)
        puts "There is no child element of root. Cannot call next_elem, while root is always only one."
        raise NoElementError
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i + 1;
        @elem_str = "#{@elem_str.slice(0, last_gt+1)}#{order}";
        return self
      end
    end
    
    def prev_elem():String
      if(@elem_str.empty?)
        puts "There is no child element of root. Cannot call next_elem, while root is always only one."
        raise NoElementError
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i;
        if(order <= 0)
          puts "Cannot decrease order. Order is already 0."
          raise NegativeOrderError
        end
        order -= 1
        return "#{@root_key}#{@elem_str.slice(0, last_gt+1)}#{order}"
      end
    end
    
    def prev_elem!():KeyElementBuilder
      if(@elem_str.empty?)
        puts "There is no child element of root. Cannot call next_elem, while root is always only one."
        raise NoElementError
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice(last_gt+1).to_i;
        if(order <= 0)
          puts "Cannot decrease order. Order is already 0."
          raise NegativeOrderError
        end
        order -= 1
        @elem_str = "#{@elem_str.slice(0, last_gt+1)}#{order}";
        return self
      end
    end
    
    def root_only?()
      @elem_str.empty?
    end
    
    def elem_name():String
      if(@elem_str.empty?)
        return @root_name
      else
        dd_split = @elem_str.split("::")
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
      if(!gt_split[gt_split.length-2] == "text")
        return -1
      end
      return gt_split[gt_split.length-1].to_i 
    end
    
    private
    def self.last_dd_gt_split(key_str):Array
      dd_split = key_str.split("::")
      if(dd_split.length < 4)
        return nil
      end
      return dd_split[dd_split.length-1].split('>')
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
      return gt_split[gt_split.length-2] == "text"
    end
          
    def self.build_from_s(key_str):KeyElementBuilder
      key_split = key_str.split("::")
      if(key_split.length < 4)
        puts "#{key_str} cannot be parsed to KeyElementBuilder. Simply said: not enough '::' delimiters."
        raise NotEnoughParametersError
      end
      
      db = key_split[0]
      col = key_split[1]
      doc = key_split[2]
      root = key_split[3]
      
      instance = new(db, col, doc, root)
       
      if(key_split.length > 4)
        (4..key_split.length-1).each { |index|
          splitted_split = key_split[index].split(">")
          if(splitted_split.length < 2)
            break
          end
          instance.elem!(splitted_split[0], splitted_split[1].to_i)
        }
      end
      
      return instance
    end
    
    def to_s():String
      "#{@root_key}#{@elem_str}"
    end
    
    attr_reader :root_key
    
  end
  
  #exceptions
  class NoElementError < StandardError
  end
  
  class NegativeOrderError < StandardError
  end
  
end