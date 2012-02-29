require_relative "key_element_builder"

module Transformer
  class Key

    private_class_method :new
    
    def initialize(db_name, col_name, doc_name)
      @db_name = db_name
      @col_name = col_name
      @doc_name = doc_name
      @db_key = db_name
      @col_key = "#{db_name}#{:"::"}#{col_name}"
      @doc_key = "#{@col_key}#{:"::"}#{doc_name}"
    end
    
    # static - creates new Key with required parameters
    def self.create(db_name, col_name, doc_name):Key
      return new(db_name, col_name, doc_name)
    end
    
    # static
    def self.collection_key(db_name, col_name):String
      "#{db_name}#{:"::"}#{col_name}"
    end
    
    def self.build_from_s(key_str):Key
      key_split = key_str.split("::")
      if(key_split.length < 3)
        puts "#{key_str} cannot be parsed to Key. Simply said: not enough '::' delimiters."
        raise NotEnoughParametersError
      end
      return new(key_split[0], key_split[1], key_split[2])
    end
    
    
    def iter():String
      "#{@col_key}#{:"<id_iterator"}"
    end
    
    def info():String
      "#{@doc_key}#{:"<info"}"
    end

    # root returns KeyElementBuilder, which require root element to initialize
    # that there is possible to create element_keys and so on    
    def root(root_name):KeyElementBuilder
      KeyElementBuilder.create(@db_name, @col_name, @doc_name, root_name)
    end
    
    def to_s():String
      @doc_key
    end
    
    attr_reader :db_key, :col_key, :doc_key
    
    class NotEnoughParametersError < StandardError
    end
    
  end
end