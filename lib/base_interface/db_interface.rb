require "singleton"
require_relative "entries_bean"

#Adding lib to LOAD_PATH e.g. $:
#NOTE: $0 contains path to the first open file, e.g. it differs when we start this file or main.rb
redis_dir = File.dirname($0) + '/../lib/'
unless $:.include?(redis_dir) || $:.include?(File.expand_path(redis_dir))
$:.unshift(File.expand_path(redis_dir))
end

#require "redis/connection/hiredis"
require "redis"

#WORKING WITH HASHES
#redis.hmset - params: key, *field_value_pairs - rewrites fields, as many pairs we want
#redis.hmget - params: key, *fields - get all values from all fields as array
#redis.hdel - params: key, *fields - delete all the given fields
#redis.hsetnx - params: key, field, value - !!!only one field at a time, set field only if the field does not exist

module BaseInterface
  #Class represents an interface between redis database and our application. It encapsulates redis commands.
  class DBInterface
    include Singleton

    @@BUFFER_COUNT = 1000000 #of all entry operations - then flush to redis
    @@STACK_LEVEL_LIMIT = 8000 #stack level too deep error prevention (@redis.mset *values)

    def initialize
      @redis = Redis.new
      
      #stats
      @add_hash_count = 0
      @add_list_count = 0
      @save_string_entries_count = 0
      @entry_exist_count = 0
      @find_value_count = 0
      @save_entries_count = 0
      
      #buffers
      @add_to_hash_buffer_nx = []
      @add_to_hash_buffer = [] #array of entries_beans
      # USAGE
      # bean = BaseInterface::EntriesBean.new(key)
      # bean.value = hash object
      # @add_to_hash_buffer << bean
      
      @add_to_list_buffer = [] #array of entries_beans
      # USAGE
      # bean = BaseInterface::EntriesBean.new(key)
      # bean.value = array of objects
      # @add_to_list_buffer << bean
      
      @save_entries_buffer_nx = []
      @save_entries_buffer = [] #list of keys following by values
      # USAGE
      # @save_entries_buffer << entry_key
      # @save_entries_buffer << entry_value
    end

    # @@redis = Redis.new
    # @@add_hash_count = 0
    # @@add_list_count = 0
    # @@save_string_entries_count = 0
    # @@entry_exist_count = 0
    # @@find_value_count = 0
    # @@save_entries_count = 0
    
    #Helper method to print number of calls of the redis methods, which are often used. Currently profiling only
    #when saving
    def print_used_commands()
      puts "Number of method calls:"
      puts "add_to_hash: #{@add_hash_count}"
      puts "add_to_list: #{@add_list_count}"
      puts "save_string_entries: #{@save_string_entries_count}"
      puts "save_entries: #{@save_entries_count}"
    end

    #WORKING WITH HASHES
    #redis.hmset - params: key, *field_value_pairs - rewrites fields, as many pairs we want
    #redis.hmget - params: key, *fields - get all values from all fields as array
    #redis.hdel - params: key, *fields - delete all the given fields
    #redis.hsetnx - params: key, field, value - !!!only one field at a time, set field only if the field does not exist

    #Saves a given array in a database as a hash under a given key, example: ["key", "value"] >> {"key" => "value"}
    def add_to_hash(key, hash, overwrite)
      @add_hash_count += 1
      #return
      
      check_buffer #buffer full? -> commit will be performed
      
      bean = BaseInterface::EntriesBean.new(key)
      bean.value = hash
      
      if overwrite
        @add_to_hash_buffer << bean
        # @redis.hmset key, *hash
      else
        @add_to_hash_buffer_nx << bean
        # fields_only = []
        # values_only = []
        # (hash.length).times do |x|
          # fields_only << hash[x] if x%2 == 0
          # values_only << hash[x] if x%2 != 0
        # end
        # #Now we have fields and values apart
        # fields_only.each_with_index do |field, index|
          # @redis.hsetnx key, field, values_only[index] #set value only if field does not exist
        # end
      end
    end

    #Adds values from a given array to a list located in a database under the given key
    def add_to_list(key, values)
      @add_list_count += 1
      #return
      
      check_buffer #buffer full? -> commit will be performed
      
      bean = BaseInterface::EntriesBean.new(key)
      bean.value = values
      @add_to_list_buffer << bean
      
      # values.each do |value|
        # @redis.rpush key, value #multiple values are not supported
                                # although they should be (someone ought to be punished for that...)
      # end
    end

    def close_connection()
      #We probably don't need this
    end

    #Increments value under the given key in a database and returns that value
    def increment_string(key)
      @redis.incr key
      @redis.get key
    end

    #Decrements value under the given key in a database and returns that value
    def decrement_string(key)
      @redis.decr key
      @redis.get key
    end

    #Deletes all values from database under the keys given as an array
    def delete_entries(keys)
      keys.each do |key|
        @redis.del key
      end
    end

    #Deletes certain pairs from hash located under the given key. Pairs are specified using an array parameter of 
    #fields==keys
    def delete_from_hash(key, *hash_keys)
      @redis.hdel key, *hash_keys
    end

    #Determines if the given field exist in a hash located under the given key
    def hash_value_exist?(key, field)
      @redis.hexists key, field
    end

    #Deletes all occurences of values specified in an array paraeter from a list under the given key.
    def delete_from_list(key, *values)
      #LREM list -2 "hello" will remove the last two occurrences of "hello" in the list stored at list. =0 means all
      values.each do |val|
        @redis.lrem key, 0, val #deletes all occurences of val
      end
    end

    #Determines if there is any value under the given key in a database
    def entry_exist?(key)
      @entry_exist_count += 1
      #return
      @redis.exists key
    end

    #Returns all valus saved under the given key. Returned value can be hash, array or string.
    def find_value(key)
      @find_value_count += 1
      #return
      type = @redis.type key
      return @redis.hgetall key if type == "hash"
      if type == "list"
      length = @redis.llen key
      return @redis.lrange key, 0, length-1 if length > 0
      return nil
      end
      return @redis.get key if type == "string"
      #We don't use set or sorted set, so return nil
      return nil
    end

    #Saves multiple string values under the multiple keys specified in an array parameter, example:
    #["key1", "string1", "key2", "string2"]
    def save_string_entries(*key_string, overwrite)
      @save_string_entries_count += 1
      #return
      
      check_buffer
      
      if(overwrite)
        key_string.each { |str|
          @save_entries_buffer << str
        }
        # @redis.mset(*key_string)
      else
        key_string.each { |str|
          @save_entries_buffer_nx << str
        }
        # @redis.msetnx(*key_string)
      end
    end

    #Saves multiple string values under the multiple keys specified in a hash parameter, example:
    #["key1" => "string1", "key2" => "string2"]
    #so basically the same function as save_string_entries with another type of parameter
    def save_entries(key_value_hash, overwrite)
      @save_entries_count += 1
      #return
      key_value_list = []
      key_value_hash.each do |key, value|
        key_value_list << key
        key_value_list << value
      end
      if(overwrite)
      @redis.mset(*key_value_list)
      else
      @redis.msetnx(*key_value_list)
      end
    end
    
    def check_buffer
      if @save_entries_buffer.length > @@STACK_LEVEL_LIMIT or @add_to_hash_buffer.length + @add_to_list_buffer.length + @save_entries_buffer.length > @@BUFFER_COUNT 
        puts "db_interface: buffer full"
        commit_after do end
      end 
    end
    
    #flush buffers - !!yield supplied before commiting!!
    def commit_after
      yield
      puts "db_interface: commiting"
      @redis.multi do
        
        #flush add_to_hash
        @add_to_hash_buffer_nx.each do |entries_bean|
          fields_only = []
          values_only = []
          hash = entries_bean.value
          (hash.length).times do |x|
            fields_only << hash[x] if x%2 == 0
            values_only << hash[x] if x%2 != 0
          end
          #Now we have fields and values apart
          fields_only.each_with_index do |field, index|
            @redis.hsetnx entries_bean.key, field, values_only[index] #set value only if field does not exist
          end
        end
        
        @add_to_hash_buffer.each { |entries_bean|
          hash = entries_bean.value
          @redis.hmset entries_bean.key, *hash
        }
        @add_to_hash_buffer = []
        
        #flush add_to_list
        @add_to_list_buffer.each { |entries_bean|
          values = entries_bean.value
          values.each do |value|
            @redis.rpush entries_bean.key, value #multiple values are not supported
                                    # although they should be (someone ought to be punished for that...)
            #should've looked like this
            #@redis.rpush entries_bean.key, *values 
          end
          
        }
        @add_to_list_buffer = []
        
        #flush key value savings
        values = @save_entries_buffer
        @redis.mset *values
        @save_entries_buffer = []
        values = @save_entries_buffer_nx
        @redis.msetnx *values
        @save_entries_buffer_nx = []
      end #end of redis.multi
    end #end of commit_after method

  end
end