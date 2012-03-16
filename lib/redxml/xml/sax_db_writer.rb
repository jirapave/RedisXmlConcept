require_relative "../xml/node"
require_relative "../xml/element"
require_relative "../xml/attributes"
require_relative "../xml/text_content"
require_relative "../transformer/key_builder"
require "rubygems"
require "nokogiri"
require "observer"
class Notifier
end

module XML
  #Class represents an event handler for Nokogiri::XML::SAX::Parser. During parsing, events like element starts
  #or element ends are raised and this class react to them. It is used to build whole elements and when
  #element is completly loaded, it is sent to document_service
  #This class is part of Observer pattern as an Observable. It's observer is document_service.
  class SaxDbWriter < Nokogiri::XML::SAX::Document
    include Observable 
    def initialize(service, mapping)
      @mapping_service = mapping
      #Service will be responsible for handling saving, we will notify it when we have complete tag loaded
      add_observer service 
      #Incomplete nodes are held in stack until end_tag arrives for them
      @stack = []
      @current_tag = nil
      #Contain nesting of elements, start_element push name to it, end_element pop from it
      @path = []
      #Like path but with nesting and order of elements
      @nesting_count = {}
      @root_element = true
      #Element names mapping to id
      @elem_mapping = {}
      #Attribute names mapping to id
      @attr_mapping = {}
    end
    
    def start_document()
    end
    
    def end_document()
      changed
        notify_observers @elem_mapping
    end
    
    def xmldecl(version, encoding, standalone)
      result = [version, encoding, standalone]
      changed
      # notify the observers
      notify_observers result
    end
    
    def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
      name = rename_elem(name)
      @stack.push(@current_tag) if @current_tag != nil
      count = 0
      
      #Example of @path: ["catalog>0", "book>0"], nesting_count hash key is created based on this path
      #to keep count of elements in a certain nesting, we have to know order of the elements
      
      if @root_element == true
        @nesting_count["#{name}"] = 0
        @root_element = false
        @path.push("#{name}")
        
        changed
        notify_observers name
      else
        count = @nesting_count[@path.join('-') + "-#{name}"]
        if count == nil
        count = 0
        @nesting_count[@path.join('-') + "-#{name}"] = 0
        end
        @nesting_count[@path.join('-') + "-#{name}"] += 1
        @path.push("#{name}>#{count}")
      end
      
      #path contains name of tags preceding this tag in nesting, for example aaa>bbb start_tag(ccc)
      parent = @path[@path.length-2] if @path.length > 1
      @current_tag = XML::Element.new(name, "", prefix, parent)
      
      attributes = {}
      attrs.each do |attr|
        attr_id = rename_attr(attr.localname)
        attributes["#{attr_id}"] = attr.value
      end
      
      @current_tag.attributes = XML::Attributes.new(name, attributes)
      @root_element = false
    end
    
    def end_element_namespace(name, prefix = nil, uri = nil)
      name = rename_elem(name)
      @path.pop()
      order = 0;
      if @path.length != 0
        order = @nesting_count[@path.join('-') + "-#{name}"] - 1
      end
      #TODO testing needed here, @nesting_count could be periodically deleted, is it needed? Memory leaks here?
      
      @current_tag.order = order
      
      #Now we will generate key for this element
      key = ""
      #puts "base_key: #{key}"
      @path.each do |path|
        info = path.split('>')
        if(info.length < 2)
          key = "#{info[0]}"
        else
          key = Transformer::KeyElementBuilder.build_from_s(@mapping_service.key_builder, key.to_s).elem(info[0], info[1])
        end
      end
      
      # all these ifs are for saving root element without order number!
      if(key == "")
        key = "#{name}"
      else
        key = Transformer::KeyElementBuilder.build_from_s(@mapping_service.key_builder, key.to_s).elem(name, order)
      end
      
      @current_tag.database_key = key
      
      changed
      # notify the observers, give them loaded node
      #Add this element's key to the children of it's parent
      @stack[@stack.length-1].add_child(@current_tag.database_key) if !@stack.empty?
      notify_observers @current_tag
      #puts @current_tag.inspect
      @current_tag = @stack.pop()
      @tag = nil
    end

    def comment(text)
      save_text_node(text, XML::TextContent::COMMENT)
    end

    #Method is called when a chunk of text occurs, each calling means one text part, for example:
    #<aaa>aaa<bbb>bbb</bbb>ccc</aaa>, for aaa element it gets called twice for "aaa" and "ccc"
    def characters(text)
      save_text_node(text, XML::TextContent::PLAIN)
    end
    
    def cdata_block(string)
      save_text_node(string, XML::TextContent::CDATA)
    end
    
    def error(string)
      
    end
    
    private
    #Method will use elem_mapping hash and lookup name, if ti does exist, it returns hash value
    #otherwise it creates new hash value with id based on size of hash
    def rename_elem(name)
      if (@elem_mapping[name] == nil)
        elem_id = @mapping_service.create_elem_mapping(name)
        puts "Mapping of element failed, this should not happend, name=#{name}" unless elem_id
        @elem_mapping[name] = elem_id
      end
      return @elem_mapping[name]
    end
    
    def rename_attr(name)
      if (@attr_mapping[name] == nil)
        attr_id = @mapping_service.create_attr_mapping(name)
        puts "Mapping of element failed, this should not happend, name=#{name}" unless attr_id
        @attr_mapping[name] = attr_id
      end
      return @attr_mapping[name]
    end
    
    def save_text_node(text, type)
      text = text.sub('\n', '').strip
      if(text.empty?)
        return
      end
      order = @current_tag.text_nodes_count
      key = ""
      #puts "base_key: #{key}"
      @path.each do |path|
        info = path.split('>')
        if(info.length < 2)
          key = @mapping_service.key_builder.root(info[0])
        else
          key.elem!(info[0], info[1].to_i)
        end
      end
      
      text_tag = XML::TextContent.new(text, order, type)
      case type
        when XML::TextContent::PLAIN
          text_tag.database_key = key.text(order)
        when XML::TextContent::COMMENT
          text_tag.database_key = key.comment(order)
        when XML::TextContent::CDATA
          text_tag.database_key = key.cdata(order)
        else
          puts "This should never happend, text_type doesn't correspond: #{type}"
          text_tag.database_key = key.text(order)
      end
      # @current_tag.descendants << text_tag
      @current_tag.add_text(text_tag)
    end
  end
end