module RedXmlApi
  class Document
    attr_reader :name, :version, :encoding, :standalone, :content
    def initialize(name, version, encoding, standalone, content)
      @name = name
      @version = version
      @encoding = encoding
      @standalone = standalone
      @content = content
    end
    
    def to_s()
      puts @content
    end
  end
end