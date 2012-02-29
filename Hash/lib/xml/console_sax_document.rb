require "rubygems"
require "nokogiri"
require "observer"

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
  class ConsoleSaxDocument < Nokogiri::XML::SAX::Document
    
    def start_document()
      puts "SAX starting"
    end
    
    def xmldecl(version, encoding, standalone)
      puts "version: #{version}, encoding: #{encoding}, standalone: #{standalone}"
    end
    
    def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
      puts "caught start: #{name}"
    end
    
    def end_element_namespace(name, prefix = nil, uri = nil)
      puts "caught end: #{name}"
    end

    def comment(text)
    end

    #Method is called when a chunk if text occurs, each calling means one text part, for example:
    #<aaa>aaa<bbb>bbb</bbb>ccc</aaa>, for aaa element it gets called twice for "aaa" and "ccc"
    def characters(text)
      puts "Text caught: #{text}"
    end
    
    def cdata_block(string)
      
    end
    
    def error(string)
      
    end
  end
end