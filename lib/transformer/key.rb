require_relative "key_element_builder"

module Transformer
  class Key

    private_class_method :new
    
    attr_reader :database_key, :collection_key, :document_key, :database_key, :collection_key, :document_key
    
    def initialize(db_name, col_name, doc_id)
      @db_name = db_name
      @col_name = col_name
      @doc_name = doc_id
      @database_key = db_name
      @collection_key = "#{db_name}#{:"::"}#{col_name}"
      @document_key = "#{@collection_key}#{:"::"}#{doc_id}"
    end
    
    class << self
      # static - creates new Key with required parameters
      def create(db_name, col_name, doc_name):Key
        return new(db_name, col_name, doc_name)
      end
    
      # static
      def collection_key(db_name, col_name):String
        "#{db_name}#{:"::"}#{col_name}"
      end
    
      def build_from_s(key_str):Key
        key_split = key_str.split("::")
        if(key_split.length < 3)
          puts "#{key_str} cannot be parsed to Key. Simply said: not enough '::' delimiters."
          raise NotEnoughParametersError
        end
        return new(key_split[0], key_split[1], key_split[2])
      end
      
      def root(root_name):KeyElementBuilder
        KeyElementBuilder.create(@db_name, @col_name, @doc_name, root_name)
      end
    end
    
    
    def iter():String
      "#{@collection_key}#{:"<id_iterator"}"
    end
    
    def info():String
      "#{@document_key}#{:"<info"}"
    end
    
    def collection_key():String
      @collection_key
    end
    
    def document_key():String
      @document_key
    end

    # root returns KeyElementBuilder, which require root element to initialize
    # that there is possible to create element_keys and so on    
    def root(root_name):KeyElementBuilder
      KeyElementBuilder.create(@db_name, @col_name, @doc_name, root_name)
    end
    
    def to_s():String
      @doc_key
    end
    
    class NotEnoughParametersError < StandardError
    end
    
  end
end