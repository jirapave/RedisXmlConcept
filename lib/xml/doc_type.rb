require_relative "node"

module XML
  class DocType < XML::Node 
    attr_accessor :internal_subset, :name, :public_id, :system_id
    def initialize(internal_subset=false, name=false, public_id=false, system_id=false)
      @internal_subset = internal_subset
      @name = name
      @public_id = public_id
      @system_id = system_id
    end
    
    def valid?()
      result = true
      result = false if @internal_subset
      result = false if @name
      result = false if @public_id
      result = false if @system_id
      result
    end
  end
end