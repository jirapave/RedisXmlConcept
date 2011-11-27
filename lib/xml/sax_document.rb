require_relative "../xml/node"
require_relative "../xml/element"
require_relative "../xml/attr"
require_relative "../xml/attributes"
require_relative "../xml/text_content"
require_relative "../transformer/key_builder"
require "rubygems"
require "nokogiri"
require "observer"
class Notifier
end

module XML
  #SAX parser is the only right way to parse really big files, so our services must cooperate with
  #this class
  #INFO: Because we have to be able to cooperate with mixed content, parsing has to change! We have to
  #use stack, for example method characters(text) gets called when a chunk of text is found:
  #<aaa>first<bbb>bbb</bbb>second</aaa>
  #callings: start_tag, characters, start_tag, end_tag, characters, end_tag
  #So we have to use stack to save nesting.
  #For now we use our own xml representation defined in XML module. Classes are used a bit
  #differently, it will be changed. For now TextContent represents one chunk of text, it's "parts" 
  #attributes is unused. Document is not used, information about document are sent directly.
  class SaxDocument < Nokogiri::XML::SAX::Document
    include Observable 
    def initialize(service, base_key)
      #Service will be responsible for handling saving, we will notify it when we have complete tag loaded
      add_observer service 
      @base_key = base_key
      @builder = Transformer::KeyBuilder
      #Incomplete nodes are held in stack until end_tag arrives for them
      @stack = []
      @current_tag = nil
      #Contain nesting of elements, start_element push name to it, end_element pop from it
      @path = []
      #Like path but with nesting and order of elements
      @nesting_count = {}
      @root_element = true
    end
    
    def start_document()
      puts "SAX starting"
    end
    
    def xmldecl(version, encoding, standalone)
      result = [version, encoding, standalone]
      changed
      # notify the observers
      notify_observers result
    end
    
    def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
      @stack.push(@current_tag) if @current_tag != nil
      count = 0
      
      #Example of @path: ["catalog>0", "book>0"], nesting_count hash key is created based on this path
      #to keep count of elements in a certain nesting, we have to know order of the elements
      
      if @root_element == true
        @nesting_count["#{name}"] = 0
        @root_element = false
      else
        count = @nesting_count[@path.join('-') + "-#{name}"]
        if count == nil
        count = 0
        @nesting_count[@path.join('-') + "-#{name}"] = 0
        end
        @nesting_count[@path.join('-') + "-#{name}"] += 1
      end
      @path.push("#{name}>#{count}")
      #path contains name of tags preceding this tag in nesting, e.g. aaa>bbb>ccc, aaa>bbb start_tag(ccc)
      parent = @path[@path.length-2] if @path.length > 1
      #Add name of this tag to it's parent child elements
      #No, we will add key of the element
      #@stack[@stack.length-1].add_child(name) if !@stack.empty?
      @current_tag = XML::Element.new(name, "", prefix, parent)
      @current_tag.attributes = XML::Attributes.new(name, attrs)
      @root_element = false
    end
    
    def end_element_namespace(name, prefix = nil, uri = nil)
      @path.pop()
      order = 0;
      if @path.length != 0
        order = @nesting_count[@path.join('-') + "-#{name}"] - 1
      end
      #TODO nesting_count has to be deleted periodically, or it could be large, it will be needed some
      #regex on keys based on the name of a apth and it's path
      
      @current_tag.order = order
      
      #Now we will generate key for this element
      key = @base_key
      #puts "base_key: #{key}"
      @path.each do |path|
        info = path.split('>')
        key = @builder.element_key(key, info[0], info[1])
      end
      key = @builder.element_key(key, name, order)
      @current_tag.database_key = key
      
      changed
      # notify the observers, give them loaded node
      @current_tag.nesting = @path.dup()
      #Add this element's key to the children of it's parent
      @stack[@stack.length-1].add_child(@current_tag.database_key) if !@stack.empty?
      notify_observers @current_tag
      #puts @current_tag.inspect
      @current_tag = @stack.pop()
      @tag = nil
    end

    def comment(text)
    end

    #Method is called when a chunk if text occurs, each calling means one text part, for example:
    #<aaa>aaa<bbb>bbb</bbb>ccc</aaa>, for aaa element it gets called twice for "aaa" and "ccc"
    def characters(text)
      order = @current_tag.text_nodes_count
      key = @base_key
      #puts "base_key: #{key}"
      @path.each do |path|
        info = path.split('>')
        key = @builder.element_key(key, info[0], info[1])
      end
      key = @builder.text_key(key, order)
      text_tag = XML::TextContent.new(false, text, order)
      text_tag.database_key = key
      @current_tag.descendants << text_tag
    end
    
    def cdata_block(string)
      
    end
    
    def error(string)
      
    end
  end
end