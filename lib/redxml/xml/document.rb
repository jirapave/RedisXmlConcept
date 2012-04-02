require_relative "node"

module XML
  # Represents Document with it's declaration and root element.
  class Document < XML::Node
    attr_accessor :doctype, :encoding, :file_name, :root_element, :standalone, :version
    def initialize(doctype=false, encoding=false, file_name=false, root=false, standalone="yes", version=false)
      @doctype = doctype
      @encoding = encoding
      @file_name = file_name
      @root_element = root
      @standalone = standalone
      @version = version
    end
    
    def metadata():String
      s = "<?xml"
      s += " encoding=\"#{@encoding}\"" if(@encoding)
      s += " standalone=\"#{@standalone}\"" if(@standalone)
      s += " version=\"#{@version}\"" if(@version)
      s += " ?>"
      return s
    end
    
    def valid?()
      result = true
      result = false if @doctype
      result = false if @encoding
      result = false if @file_name
      result = false if @root_element
      result = false if @standalone.to_s == "none"
      result = false if @version
      result
    end
  end
end