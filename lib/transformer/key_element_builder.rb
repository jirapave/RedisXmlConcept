require_relative "../xml/text_content"
require_relative "key_builder"
require_relative "exceptions"

module Transformer
  
  # This class is used to create keys according to our proprietary mapping. It also supports
  # veryfying the type of the key. For the detailed info about mapping, see {Mapping overview}[https://github.com/jirapave/RedisXmlConcept/wiki/Mapping-overview]
  class KeyElementBuilder
    
    # Separator of elements in the key
    SEPARATOR = ":"
    
    # Key of iterator, which is used to create new ids
    ITERATOR_KEY = "<iterator>"
    
    # Attributes with a root id = root key
    attr_reader :root_key, :key_builder
    
    # Minimal value of order of the element (first descendant, second...cannot be zero or lower)
    MIN_ORDER = 1

    # Creates new instance of KeyElementBuilder using existing KeyBuilder and root_id.
    # ==== Parameters
    # * +key_builder+ - Instance of KeyBuilder class
    # * +root_id+ - Id of the root element. 
    def initialize(key_builder, root_id)
      @root_key = "#{root_id}"
      @elem_str = ""
      @key_builder = key_builder
    end
    
    # Creates new instance of KeyElementBuilder with new element added to the key with certain order.
    # ==== Parameters
    # * +elem_id+ - Id of the element, which is added to the key
    # * +order+ - Order of the element
    # ==== Return value
    # KeyElementBuilder
    def elem!(elem_id, order)#:KeyElementBuilder
      @elem_str += "#{SEPARATOR}#{elem_id}>#{order}"
      return self
    end
    
    # Creates a string representing current key with added element and order
    # ==== Parameters
    # * +elem_id+ - Id of the element, which is added to the key
    # * +order+ - Order of the element
    # ==== Return value
    # String representing a hash field where element content is hold
    def elem(elem_id, order)#:String
      "#{self.to_s}#{SEPARATOR}#{elem_id}>#{order}"
    end

    # Creates a string representing current key with added attribute suffix
    # ==== Return value
    # String representing a hash field where attributes of the certain element are hold
    def attr()#:String
      "#{self.to_s}<a"
    end
    
    # Creates a string representing current key with added text element suffix of the certain order
    # ==== Return value
    # String representing a hash field where text content of the certain text node is hold
    def text(order)#:String
      "#{@root_key}#{@elem_str}>t>#{order}"
    end
    
    # Creates a string representing current key with added comment element suffix of the certain order
    # ==== Return value
    # String representing a hash field where text content of the certain comment is hold
    def comment(order)#:String
      "#{@root_key}#{@elem_str}>c>#{order}"
    end
    
    # Creates a string representing current key with added CDATA suffix of the certain order
    # ==== Return value
    # String representing a hash field where text content of the certain CDATA is hold
    def cdata(order)#:String
      "#{@root_key}#{@elem_str}>d>#{order}"
    end
    
    # Creates new instance of KeyElementBuilder with the key of parent of current element 
    # ==== Return value
    # KeyElementBuilder
    # ==== Raises
    # Transformer::NoElementError - When there is no parent of the current element
    def parent!()#:KeyElementBuilder
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no parent element for root element."
      else
        last_separator = @elem_str.rindex(SEPARATOR)
        @elem_str = @elem_str.slice(0, last_separator);
        return self
      end
    end
    
    # Creates a string of the key of parent of current element 
    # ==== Return value
    # String of the created key
    # ==== Raises
    # Transformer::NoElementError - When there is no parent of the current element
    def parent()#:String
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no parent element for root element."
      else
        last_separator = @elem_str.rindex(SEPARATOR)
        return "#{@root_key}#{@elem_str.slice(0, last_separator)}"
      end
    end
    
    # Creates a string with last part of the element key after the last separator.
    # ==== Return value
    # String of the created key
    # ==== Raises
    # Transformer::NoElementError - When there is no parent of the current element
    def last_part_only()
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no parent element for root element."
      else
        last_separator = @elem_str.rindex(SEPARATOR)
        return "#{@elem_str.slice(last_separator+1, @elem_str.length)}"
      end
    end
    
    # Creates a string of the current key with changed order (+1)
    # ==== Return value
    # String of the created key
    # ==== Raises
    # Transformer::NoElementError - When this method is called on a root element key
    #
    # ==== Examples 
    # How the key will be changed
    #    builder = KeyElemntBuilder.build_from_s("1:1>2>t>1:34>3")
    #    puts builder.prev_elem #prints 1:1>2>t>1:34>4 
    def next_elem()#:String
      if(@elem_str.empty?)
        raise Transformer::NoElementError, "There is no child element of root. Cannot call next_elem, while root is always only one."
      else
        last_gt = @elem_str.rindex(">")
        order = @elem_str.slice((last_gt+1)..-1).to_i + 1;
        return "#{@root_key}#{@elem_str.slice(0, last_gt+1)}#{order}"
      end
    end
    
    # Creates new instance of KeyElmentbuilder with new key with changed order (+1)
    # ==== Return value
    # KeyElementBuilder with newly created key
    # ==== Raises
    # Transformer::NoElementError - When this method is called on a root element key
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
    
    # Creates a string of the current key with changed order (-1)
    # ==== Return value
    # String of the created key
    # ==== Raises
    # Transformer::NoElementError - When this method is called on a root element key
    # Transformer::WrongOrderError - When called on the first element (there is no zero element)
    #
    # ==== Examples 
    # How the key will be changed
    #    builder = KeyElemntBuilder.build_from_s("1:1>2>t>1:34>3")
    #    puts builder.prev_elem #prints 1:1>2>t>1:34>2 
    def prev_elem()
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
    
    # Creates new instance of KeyElmentbuilder with new key with changed order (-1)
    # ==== Return value
    # KeyElementBuilder with newly created key
    # ==== Raises
    # Transformer::NoElementError - When this method is called on a root element key
    # Transformer::WrongOrderError - When called on the first element (there is no zero element)
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
    
    # Check if the current key points to a plain root element
    # ==== Return value
    # True if the current key points to root, otherwise False
    def root_only?()
      @elem_str.empty?
    end
    
    # Obtain id of the current element
    # ==== Return value
    # String with an id of the current element
    #
    # ==== Examples 
    # Which id is obtained:
    #    builder = KeyElemntBuilder.build_from_s("1:1>2>t>1:34>3")
    #    puts builder.elem_id #prints 34  
    def elem_id()#:String
      if(@elem_str.empty?)
        return @root_key
      else
        dd_split = @elem_str.split(SEPARATOR)
        return dd_split[dd_split.length-1].split('>')[0]
      end
      
    end
    
    # Obtain order of the current element
    # ==== Return value
    # Integer with an order of the current element
    #
    # ==== Examples 
    # Which order is obtained:
    #    builder = KeyElemntBuilder.build_from_s("1:1>2>t>1:34>3")
    #    puts builder.order #prints 3  
    def order()#:Integer
      if(@elem_str.empty?)
        raise WrongOrderError, "Cannot return order of the root element."
      else
        gt_split = @elem_str.split('>')
        return gt_split[gt_split.length-1].to_i 
      end
    end
    
    # Obtain order of the text element of the given key
    # ==== Parameters
    # * +key_str+ - Valid key string ending with a text element
    # ==== Return value
    # Integer with an order of the text element of the given key
    # ==== Raises
    # Transformer::WrongOrderError - When thekey is on pointing to text element (no text order could be parsed)
    #
    # ==== Examples 
    # Which order is obtained:
    #    puts KeyElemntBuilder.text_order("1:1>2>t>1:34>3") #Error, this is no text key
    #    puts KeyElemntBuilder.text_order("1:1>2>t>1:34>3>t>4") #prints 4
    def self.text_order(key_str)
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
    def self.last_dd_gt_split(key_str)# :nodoc:
      dd_split = key_str.split(SEPARATOR)
      if(dd_split.length < 1)
        return nil
      end
      return dd_split[-1].split('>')
    end
    
    def self.text_type?(key_str, type)# :nodoc:
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
    # Verifies if the given key points to plain text
    # ==== Parameters
    # * +key_str+ - String of the valid key
    # ==== Return value
    # True if key points to plain text, False otherwise
    def self.text?(key_str)
      self.text_type?(key_str, XML::TextContent::PLAIN)
    end
    
    # Verifies if the given key points to comment
    # ==== Parameters
    # * +key_str+ - String of the valid key
    # ==== Return value
    # True if key points to comment, False otherwise
    def self.comment?(key_str)
      self.text_type?(key_str, XML::TextContent::COMMENT)
    end
    
    # Verifies if the given key points to CDATA
    # ==== Parameters
    # * +key_str+ - String of the valid key
    # ==== Return value
    # True if key points to CDATA False otherwise
    def self.cdata?(key_str)
      self.text_type?(key_str, XML::TextContent::CDATA)
    end  
    
    # Obtain type of the text key (plain, comment, CDATA)
    # ==== Parameters
    # * +key_str+ - String of the valid key
    # ==== Return value
    # XML::TextContent::PLAIN if it's plain text, XML::TextContent::COMMENT if it's comment,
    # XML::TextContent::CDATA if it's CDATA, False otherwise
    def self.text_type(key_str)
      gt_split = self.last_dd_gt_split(key_str)
      if(gt_split == nil)
        return false
      end
      if(gt_split.length < 3)
        return false
      end
      case gt_split[-2]
          when "t"
            return XML::TextContent::PLAIN
          when "c"
            return XML::TextContent::COMMENT
          when "d"
            return XML::TextContent::CDATA
          else
            return false
        end
    end
    
    # Verifies if the given key is element key
    # ==== Parameters
    # * +key_str+ - String of the valid key
    # ==== Return value
    # True if key points to element, False otherwise
    #
    # ==== Examples 
    # Which key is element:
    #    puts KeyElemntBuilder.element?("1:1>2>t>1:34>3") #True
    #    puts KeyElemntBuilder.element?("1:1>2>t>1:34>3>t>4") #False, text content is not element
    def self.element?(key_str)
      gt_split = self.last_dd_gt_split(key_str)
      if(gt_split.length < 3 or gt_split == nil)
        return true
      else
        return false
      end
    end
     
    # Creates new instance of KeyElementBuilder from the given string and KeyBuilder.
    # ==== Parameters
    # * +key_str+ - String of the valid key
    # * +ke_builder+ - KeyBuilder
    # ==== Return value
    # KeyElementBuilder
    # ==== Raises
    # NotEnoughParametersError - When key_str is not a valid key    
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
    
    # Creates String with the key of this KeyElementBuilder instance
    # ==== Return value
    # String of the key
    def key_str()
      return "#{@root_key}#{@elem_str}"
    end
    
    # Creates String with the key of this KeyElementBuilder instance
    # ==== Return value
    # String of th key
    def to_s()#:String
      return key_str()
    end
    
  end
  
end