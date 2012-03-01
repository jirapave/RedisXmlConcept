require_relative "../base_interface/db_interface"
require_relative "exceptions"
require_relative "key_builder"

module Transformer
  #Class is used to map environment, collection, file and element names to their ids and reverse.
  class MappingService
    
    ENV_KEY = "env"
    COLL_KEY = "coll"
    DOC_KEY = "doc"
    
    attr_accessor :key_builder
    
    #db_interface insttance is obtained in almost each method, unfortunately, we are unable to create
    #class variable of db_interfacem, because by the time we call static method, instance is not ready
    #yet and error is produced
    
    def initialize(key_builder)
      #KeyElementBuilder will be created here and used as a basis for mapping of elements and attributes
      @key_builder = key_builder
      @db_interface = BaseInterface::DBInterface.instance
      @elem_hash = @db_interface.find_value(@key_builder.elem_mapping_key)
      @attr_hash = @db_interface.find_value(@key_builder.attr_mapping_key)
      @elem_hash ||= {}
      @attr_hash ||= {}
    end
    
    def refresh_hash_mapping()
      @elem_hash = @db_interface.find_value(@key_builder.elem_mapping_key)
      @attr_hash = @db_interface.find_value(@key_builder.attr_mapping_key)
    end
    
    def create_elem_mapping(elem_name)
      elem_id = @db_interface.increment_hash(@key_builder.elem_mapping_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1, true)
      result = @db_interface.add_to_hash_ne(@key_builder.elem_mapping_key, elem_name, elem_id, true)
      if result
        @elem_hash[elem_name] = elem_id
        return elem_id
      end
      false
    end
    
    def create_attr_mapping(attr_name)
      attr_id = @db_interface.increment_hash(@key_builder.attr_mapping_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1, true)
      result = @db_interface.add_to_hash_ne(@key_builder.attr_mapping_key, attr_name, attr_id, true)
      if result
        @attr_hash[attr_name] = attr_id
        return attr_id
      end
      false
    end

    def self.map_env(env_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      env_id
    end
    
    def self.map_coll(env_id, coll_name)
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id), coll_name, "Collection")
      coll_id
    end
    
    def self.map_doc(env_id, coll_id, doc_name)
      doc_id = self.map_to_id(Transformer::KeyBuilder.documents_key(env_id, coll_id), doc_name, "Document")
      doc_id
    end

    def self.map_env_coll(env_name, coll_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id), coll_name, "Collection")
      result = {ENV_KEY => env_id, COLL_KEY => coll_id}
      result
    end
    
    def self.map_env_coll_doc(env_name, coll_name, doc_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id), coll_name, "Collection")
      doc_id = self.map_to_id(Transformer::KeyBuilder.documents_key(env_id, coll_id), doc_name, "Document")
      
      result = {ENV_KEY => env_id, COLL_KEY => coll_id, DOC_KEY => doc_id}
      result
    end

    def map_elem_name(elem_name)
      elem_id = @elem_hash[elem_name]
      raise Transformer::MappingException, "Element #{elem_name} does not have mapping to id" unless elem_id
      elem_id
    end

    def map_attr_name(attr_name)
      attr_id = @attr_hash[attr_name]
      raise Transformer::MappingException, "Attribute #{attr_name} does not have mapping to id" unless attr_id
      attr_id
    end

    def self.unmap_env(env_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      env_name
    end

#TODO Mapping completion
    def self.unmap_coll(env_id, coll_id)
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      coll_name
    end
    
    def self.unmap_doc(env_id, coll_id, doc_id)
      doc_mapping_key = Transformer::KeyBuilder.documents_key(env_id, coll_id)
      doc_name = self.unmap_hash(doc_mapping_key, doc_id)
      doc_name
    end

    def self.unmap_env_coll(env_id, coll_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      
      result = {ENV_KEY => env_name, COLL_KEY => coll_name}
      result
    end

    def self.unmap_env_coll_doc(env_id, coll_id, doc_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      
      doc_mapping_key = Transformer::KeyBuilder.documents_key(env_id, coll_id)
      doc_name = self.unmap_hash(doc_mapping_key, doc_id)
      
      result = {ENV_KEY => env_name, COLL_KEY => coll_name, DOC_KEY => doc_name}
      result
    end

    def unmap_elem_name(elem_id)
      elem_name = Transformer::MappingService.find_hash_key(@elem_hash, elem_id)
      raise Transformer::MappingException, "Mappping for element with id:#{elem_id} does not exist" unless elem_name
      elem_name
    end

    def unmap_attr_name(attr_id)
      attr_name = Transformer::MappingService.find_hash_key(@attr_hash, attr_id)
      raise Transformer::MappingException, "Mapping for attribute with id:#{attr_name} does not exist" unless attr_name
      attr_name
    end
    
    private
    def self.map_to_id(key, name, description)
      db_interface = BaseInterface::DBInterface.instance
      id = db_interface.get_hash_value(key, name)
      raise Transformer::MappingException, "#{description} #{name} does not have mapping to id = does not exist" unless id
      id
    end
    
    def self.unmap_hash(hash_key, id)
      db_interface = BaseInterface::DBInterface.instance
      mapping_hash = db_interface.find_value(hash_key)
      name = self.find_hash_key(mapping_hash, id)
      raise Transformer::MappingException, "Environment #{id} does not have mapping to name = does not exist" unless name
      name
    end
    
    def self.find_hash_key(hash, id)
      name = nil
      hash.each do |field, value|
        if value == id and field != "<iterator>"
          name = field 
          break
        end
      end
      name
    end
    
  end
end