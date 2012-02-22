require_relative "../base_interface/db_interface"
require_relative "exceptions"
require_relative "key_builder"

module Transformer
  #Class is used to map environment, collection, file and element names to their ids and reverse.
  class MappingService
    
    ENV_KEY = "env"
    COLL_KEY = "coll"
    DOC_KEY = "doc"
    
    private_class_method :new
    
    attr_accessor :key_builder
    
    #db_interface insttance is obtained in almost each method, unfortunately, we are unable to create
    #class variable of db_interfacem, because by the time we call static method, instance is not ready
    #yet and error is produced
    
    def initialize(key_builder)
      #KeyElementBuilder will be created here and used as a basis for mapping of elements and attributes
      @key_builder = key_builder
    end

    def self.create(key_builder)
      return new(key_builder)
    end
    
    def create_elem_mapping(elem_name)
      db_interface = BaseInterface::DBInterface.instance
      elem_id = db_interface.increment_hash(@key_builder.elem_mapping_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = db_interface.add_to_hash_ne(@key_builder.elem_mapping_key, elem_name, elem_id)
      return elem_id if result
      false
    end
    
    def create_attr_mapping(attr_name)
      db_interface = BaseInterface::DBInterface.instance
      attr_id = db_interface.increment_hash(@key_builder.attr_mapping_key, Transformer::KeyElementBuilder::ITERATOR_KEY, 1)
      result = db_interface.add_to_hash_ne(@key_builder.attr_mapping_key, attr_name, attr_id)
      return attr_id if result
      false
    end

    def self.map_env(env_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      env_id
    end

    def self.map_env_coll(env_name, coll_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id, false), coll_name, "Collection")
      result = {ENV_KEY => env_id, COLL_KEY => coll_id}
      result
    end
    
    def self.map_env_coll_doc(env_name, coll_name, file_name)
      env_id = self.map_to_id(Transformer::KeyBuilder.environments_key, env_name, "Environment")
      coll_id = self.map_to_id(Transformer::KeyBuilder.collections_key(env_id, false), coll_name, "Collection")
      doc_id = self.map_to_id(Transformer::KeyBuilder.documents_key(env_id, coll_id, false), file_name, "Document")
      
      result = {ENV_KEY => env_id, COLL_KEY => coll_id, DOC_KEY => doc_id}
      result
    end

    def map_elem_name(elem_name)
      db_interface = BaseInterface::DBInterface.instance
      elem_id = db_interface.get_hash_value(@key_builder.elem_mapping_key, elem_name)
      raise Transformer::MappingException, "Element #{elem_name} does not have mapping to id" unless elem_id
      elem_id
    end

    def map_attr_name(attr_name)
      db_interface = BaseInterface::DBInterface.instance
      attr_id = db_interface.get_hash_value(@key_builder.attr_mapping_key, attr_name)
      raise Transformer::MappingException, "Element #{attr_name} does not have mapping to id" unless attr_id
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
      
      result = {ENV_KEY => env_name, COLL_KEY => coll_name}
      result
    end

    def self.unmap_env_coll_doc(env_id, coll_id, doc_id)
      env_mapping_key = Transformer::KeyBuilder.environments_key
      env_name = self.unmap_hash(env_mapping_key, env_id)
      
      coll_mapping_key = Transformer::KeyBuilder.collections_key(env_id, false)
      coll_name = self.unmap_hash(coll_mapping_key, coll_id)
      
      doc_mapping_key = Transformer::KeyBuilder.documents_key(env_id, coll_id, false)
      doc_name = self.unmap_hash(doc_mapping_key, doc_id)
      
      result = {ENV_KEY => env_name, COLL_KEY => coll_name, DOC_KEY => doc_name}
      result
    end

    def unmap_elem_name(elem_id)
      elem_name = Transformer::MappingService.unmap_hash(@key_builder.elem_mapping_key, elem_id)
      elem_name
    end

    def unmap_attr_name(attr_id)
      attr_name = Transformer::MappingService.unmap_hash(@key_builder.attr_mapping_key, attr_id)
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
      name = nil
      mapping_hash.each do |field, value|
        name = field if value == id and field != "<iterator>"
      end
      raise Transformer::MappingException, "Environment #{id} does not have mapping to name = does not exist" unless name
      name
    end
    
  end
end