require_relative "../xml/node"
require_relative "../xml/element"
require_relative "../xml/attributes"
require_relative "../xml/text_content"
require_relative "../transformer/key_builder"
require "rubygems"
require "nokogiri"

module XML
  #Class represents an event handler for Nokogiri::XML::SAX::Parser. During parsing, events like element starts
  #or element ends are raised and this class react to them. It is used to build whole elements and when
  #element is completly loaded, it is sent to document_service
  #This class is part of Observer pattern as an Observable. It's observer is document_service.
  class SaxDomCreator < Nokogiri::XML::SAX::Document
    # Get the current content of DOM documnt
    attr_reader :document
    def initialize(red_xml_resource)
      @resource = red_xml_resource
      #Incomplete nodes are held in stack until end_tag arrives for them
      @stack = []
      @current_tag = nil
      @document = nil
      
      #Contain nesting of elements, start_element push name to it, end_element pop from it
      @path = []
      #Like path but with nesting and order of elements
      @nesting_count = {}
      @root_element = true
    end
    
    def start_document()
      if @document == nil #xmldecl is called before start_document
        builder = Nokogiri::XML::Builder.new 
        @document = builder.doc
      end
    end
    
    def end_document()
      @resource.set_content_as_dom(@document)
    end
    
    def xmldecl(version, encoding, standalone)
      doc = "<?xml version=\"#{version}\" encoding=\"#{encoding}\" standalone=\"#{standalone}\" ?>"
      @document = Nokogiri::XML(doc)
    end
    
    def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])      
      @stack.push(@current_tag) if @current_tag != nil
      name = [prefix, name].compact.join(':')
      attribs = ns.map { |ns_prefix,ns_uri|
        [['xmlns', ns_prefix].compact.join(':'), ns_uri]
      } + attrs.map { |attr|
        [[attr.prefix, attr.localname].compact.join(':'), attr.value]
      }
      
      attributes = {}
      attribs.each do |attr|
        attributes["#{attr[0]}"] = attr[1]
      end
      work_with = @document
      work_with = @current_tag if @current_tag
      Nokogiri::XML::Builder.with(work_with) do |xml|
        xml.send("#{name}", attributes) do |elem_xml|
          @current_tag = xml.parent
        end
      end
    end
    
    def end_element_namespace(name, prefix = nil, uri = nil)
      @current_tag = @stack.pop()
    end

    def comment(text)
      Nokogiri::XML::Builder.with(@current_tag) do |xml|
        xml.comment(text)
      end
    end

    #Method is called when a chunk of text occurs, each calling means one text part, for example:
    #<aaa>aaa<bbb>bbb</bbb>ccc</aaa>, for aaa element it gets called twice for "aaa" and "ccc"
    def characters(text)
      Nokogiri::XML::Builder.with(@current_tag) do |xml|
        xml.text(text)
      end
      
      #@current_tag.add_child(text_node)
    end
    
    def cdata_block(string)
      Nokogiri::XML::Builder.with(@current_tag) do |xml|
        xml.cdata(string)
      end
    end
    
    def error(string)
      
    end
  end
end