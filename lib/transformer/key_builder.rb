module Transformer
  #Maybe change it completly? New idea: what if we change keybuilder into key, key has getter 
  #and all these methods, so we can than do something like:
  #key.databa(db).collection(col).attributes_key().text
  class KeyBuilder
    private_class_method :new
    class << self
      def attributes_key(key)
        return "#{key}<attributes"
      end

      def attributes_order_key(key)
        if(key =~ /<attributes$/)
          return "#{key}<order"
        end
        return "#{key}<attributes<order"
      end

      def collection(key, name)
        return "#{key}::#{name}" #TODO nepamatuju se uz, co to melo vracet
      end
      
      #Iterator for each collection, used to determine id
      def iterator_key(key)
        all_double_double_dots = (0 .. key.length - 1).find_all { |i| key[i,2] == "::" }
        if(all_double_double_dots.length > 1)
          return "#{key.slice(0, all_double_double_dots[1])}<id_iterator"
        end
        return "#{key}<id_iterator"
      end

      def database(name) #TODO tady taky nevim
        return name
      end

      def count_key(key)
        return "#{key}<count"
      end

      def document_info(key)
        all_double_double_dots = (0 .. key.length - 1).find_all { |i| key[i,2] == "::" }
        if(all_double_double_dots.length > 2)
          return "#{key.slice(0, all_double_double_dots[2])}<info"
        end
        return "#{key}<info"
      end
      
      def document_key(key, id)
        #TODO
        result = key + "::#{id}"
        return result
      end

      def element_key(key, element_name, order)
        return "#{key}::#{element_name}>#{order}"
      end
      
      def next_element_key(key)
        index = key.rindex(">")
        number = key.slice(index+1).to_i + 1;
        return "#{key.slice(0, index)}>#{number}"
      end

      def parent_key(key)
        index = key.rindex("::")
        return key.slice(0, index)        
      end

      def root_key(key)
        index = key.index(">")
        if(index < 0)
          return key.slice(0, key.rindex("::"))
        end
        sub = key.slice(0, index)
        return sub.slice(0, sub.rindex("::"))
      end

      def text_key(key, order)
        return "#{key}>text>#{order}"
      end
    end
  end
end