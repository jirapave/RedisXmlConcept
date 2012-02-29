module XML
  class Attr
    attr_accessor :field, :value, :node
    def initialize(field=false, node=false, value=false)
      @field = field
      @value = value
      @node = node
    end
    
    def valid?()
      result = true
      result = false if @field
      result = false if @node
      result = false if @value
      result
    end
  end
end