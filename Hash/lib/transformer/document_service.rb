require_relative "xml_transformer"
require_relative "../xml/document"
require_relative "../xml/console_sax_document"
require_relative "../base_interface/db_interface"
require "nokogiri"
require "observer"
class Notifier
end

module Transformer
  #Class represents a service used to work with whole XML files. It can saves them to the database, verify
  #their existence in a database and also retrives them.
  #This class is part of Observer pattern as Notifier, it get's notified by XML::SaxDocument class.
  class DocumentService < Notifier
    def initialize()
      @xml_transformer = Transformer::XMLTransformer.new()
      db = BaseInterface::DBInterface.instance
      @db_interface = db
      @builder = Transformer::KeyBuilder
    end
    
    #This method gets called when a whole element or document information is retrived during
    #SAX parsing. This information is than saved to the database using XML::Transformer
    def update(value)
      if value.instance_of? Array
          #Document information are here, [version, encoding, standalone]
          
          #document_info don't work yet
          key = @builder.document_info(@base_key)
          key = @base_key + "<info"
          field_values = []
          field_values << "name" << @doc_name
          field_values << "version" << value[0] if value[0] != nil
          field_values << "encoding" << value[1] if value[1] != nil
          field_values << "standalone" << value[2] if value[2] != nil
          @db_interface.add_to_hash(key, field_values, false)
      elsif value.instance_of? String
        #Root element name
        key = @builder.document_info(@base_key)
        info = ["root", "#{@base_key}::#{value}"]
        @db_interface.add_to_hash(key, info, false)
      else
        #Element here
        @xml_transformer.save_node(value)
      end
    end
    
    #Method will save a given file to the given database under the given collection if it doensn't
    #already exist. SAX parser is used to parse an XML file.
    def save_document(database=-1,collection=-1, file_name)
      puts "CUTTING service proceeding..."
      @xml_transformer.collection = collection
      @xml_transformer.database = database
      @doc_name = file_name
      @database = database
      @collection = collection
      return false if document_exist?(file_name)
      #Read about KeyBuilder in class description, new idea about how to change it to be more effective, this
      #is horrible
      key = @builder.database(@database)
      key = @builder.collection(key, @collection)
      iter_key = @builder.iterator_key(key)
      #We will need this key as a base for others
      id_value = "id-1"
      id_value = @db_interface.increment_string(iter_key)
      @base_key = @builder.document_key(key, id_value)
      info = [@doc_name, id_value]
      puts "Saving document: #{info.inspect}"
      @db_interface.add_to_hash(key, info, false)
      
      #Now file is saved, we have it's id and we can know proceed to parsing
      parser = Nokogiri::XML::SAX::Parser.new(XML::SaxDocument.new(self, @base_key))
      # parser = Nokogiri::XML::SAX::Parser.new(XML::ConsoleSaxDocument.new)
      
      #Main idea here is to SAX parser, events should be handled by SaxDocument, which
      #will prepare whole nodes and when the node ends, it will send event here (update method) so we
      #can use XmlTranformer to save it.
      puts "Parsing in progress..."
      
      #TODO check functionality
      @db_interface.transaction do
        parser.parse(File.open(file_name, 'rb'))
      end
      puts "Document saved"
    end
    
    def all_documents(database=-1,collection=-1)
      
    end
    
    #Finds a document in a database, returns XML::Document with whole DOM loaded.
    def find_document(document)#:XML::Document
      if(!@collection or !@database)
        puts "Collection or database not set -> collection: #{@collection}, database: #{@database}"
        return nil
      end
      return find_file(document.file_name, @database, @collection)
    end
    
    #Finds a document under the specified database and collection, returns XML::Document with whole DOM loaded.
    def find_file(file_name, database=-1, collection=-1)#:XML::Document
      col_key = Transformer::Key.collection_key(database, collection)
      all_files = @db_interface.find_value(col_key)
      
      file_id = nil
      if all_files != nil 
        all_files.each do |key, value|
          if(key == file_name)
            file_id = value
            break
          end
        end
      end
      
      if(file_id == nil)
        puts "File with name #{file_name} not found."
        return nil
      end
      
      key = Transformer::Key.create(database, collection, file_id)
      return @xml_transformer.find_node(key)
    end
      
    def remove_document(document)
      
    end
    
    def remove_file(file_name, database=-1, collection=-1)
      
    end
    
    def rename_document(document, name)
      
    end
    
    def rename_file(file_name, database=-1. collection=-1)
      
    end
    
    def update_document(file_name, document)
      
    end
    
    #Verifies if a document with a given name exist. Database and collection should be specified before using 
    #this method.
    def document_exist?(file_name)
      key = @builder.database(@database)
      key = @builder.collection(key, @collection)
      return true if @db_interface.hash_value_exist?(key, file_name)
      return false
    end
    
  end
end