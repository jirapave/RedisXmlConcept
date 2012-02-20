require_relative "../base_interface/db_interface"
require_relative "key_builder"

module Transformer

  @@db_interface = BaseInterface::DBInterface.instance
  #Class is used to map environment, collection, file and element names to their ids and reverse.
  class MappingHelper
    private_class_method :new
    
    attr_accessor :key_builder
    
    def initialize(key_builder)
      #KeyElementBuilder will be created here and used as a basis for mapping of elements and attributes
      @key_builder = key_builder
      @db_interface = BaseInterface::DBInterface.instance
    end

    def self.create(key_builder)
      return MappingHelper.new(key_builder)
    end

    def self.map_env(env_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      env_id
    end

    def self.map_env_coll(env_name, coll_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id, false), coll_name, "Collection")
      result = {"env" => env_id, "coll" => coll_id}
      result
    end
    
    def self.map_env_coll_doc(env_name, coll_name, file_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id, false), coll_name, "Collection")
      doc_id = self.map_to_id(Transformer::KeyBuilder.documents_key(env_id, coll_id, false), file_name, "Document")
      
      result = {"env" => env_id, "coll" => coll_id, "doc" => doc_id}
      result
    end

    def map_elem_name(elem_name)
      elem_id = @db_interface.get_hash_value(@key_builder.elem_mapping_key, elem_name)
      raise NoMappingFoundError, "Element #{elem_name} does not have mapping to id" unless elem_id
      elem_id
    end

    def map_attr_name(attr_name)
      attr_id = @db_interface.get_hash_value(@key_builder.attr_mapping_key, attr_name)
      raise NoMappingFoundError, "Element #{attr_name} does not have mapping to id" unless attr_id
      attr_id
    end

    def self.unmap_env(env_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      env_name
    end

    def self.unmap_env_coll(env_id, coll_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id, false)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      
      result = {"env" => env_name, "coll" => coll_name}
      result
    end

    def self.unmap_env_coll_doc(env_id, coll_id, doc_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id, false)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      
      doc_mapping_key = Transformer::KeyBuilder.documents_key(env_id, coll_id, false)
      doc_name = self.unmap_hash(doc_mapping_key, doc_id)
      
      result = {"env" => env_name, "coll" => coll_name, "doc" => doc_name}
      result
    end

    def unmap_elem_name(elem_id)
      elem_name = self.unmap_hash(@key_builder.elem_mapping_key, elem_id)
      elem_name
    end

    def unmap_attr_name(attr_id)
      attr_name = self.unmap_hash(@key_builder.attr_mapping_key, attr_id)
      attr_name
    end
    
    class NoMappingFoundError < StandardError
      def message
        "No mapping from name to id was found, mapping doesn't exist."
      end
    end
    
    private
    def self.map_to_id(key, name, description)
      id = @db_interface.get_hash_value(key, name)
      raise NoMappingFoundError, "#{description} #{name} does not have mapping to id = does not exist" unless id
      doc_id
    end
    
    def self.unmap_hash(hash_key, id)
      mapping_hash = @db_interface.find_value(hash_key)
      name = nil
      mapping_hash.each do |field, value|
        name = field if value == id
      end
      raise NoMappingFoundError, "Environment #{id} does not have mapping to name = does not exist" unless name
      name
    end
    
  end
end