require "singleton"

#I don't want to rewrite redis-rb requires, so i need to add that folder into load_path, where require searches.
#$0 is a path to this file, $: is LOAD_PATH.
#NOTE: $0 contains path to the first open file, e.g. it differs when we start this file or main.rb
#We have to find a better way to do this..
redis_dir = File.dirname($0) + '/../lib/'
unless $:.include?(redis_dir) || $:.include?(File.expand_path(redis_dir))
$:.unshift(File.expand_path(redis_dir))
end
require "redis"

#WORKING WITH HASHES
#redis.hmset - params: key, *field_value_pairs - rewrites fields, as many pairs we want
#redis.hmget - params: key, *fields - get all values from all fields as array
#redis.hdel - params: key, *fields - delete all the given fields
#redis.hsetnx - params: key, field, value - !!!only one field at a time, set field only if the field does not exist

module BaseInterface
  class DBInterface
    include Singleton
    
    @@redis = Redis.new

    #WORKING WITH HASHES
    #redis.hmset - params: key, *field_value_pairs - rewrites fields, as many pairs we want
    #redis.hmget - params: key, *fields - get all values from all fields as array
    #redis.hdel - params: key, *fields - delete all the given fields
    #redis.hsetnx - params: key, field, value - !!!only one field at a time, set field only if the field does not exist
    
    #Hash could be just array? 
    def add_to_hash(key, hash, overwrite)
      if overwrite
        puts "Setting hash and overwriting:"
        puts "#{hash.inspect}"
      @@redis.hmset key, *hash
      else
        fields_only = []
        values_only = []
        (hash.length).times do |x|
          fields_only << hash[x] if x%2 == 0
          values_only << hash[x] if x%2 != 0
        end
        #Now we have fields and values apart
        fields_only.each_with_index do |field, index|
          @@redis.hsetnx key, field, values_only[index] #set value only if field does not exist
        end
      end
    end

    def add_to_list(key, values)
      values.each do |value|
        @@redis.rpush key, value
      end
    end

    def close_connection()
      #We probably don't need this
    end

    #Returns incremented value, we will always immediately need it, so we will retrieve it here
    def increment_string(key)
      @@redis.incr key
      @@redis.get key
    end

    def decrement_string(key)
      @@redis.decr key
    end

    def delete_entries(keys)
      keys.each do |key|
        @@redis.del key
      end
    end

    def delete_from_hash(key, *hash_keys)
      @@redis.hdel key, *hash_keys
    end
    
    def hash_value_exist?(key, field)
      @@redis.hexists key, field
    end

    #What values means? Is it indexes or String values? For now use it as String values
    def delete_from_list(key, *values)
      #LREM list -2 "hello" will remove the last two occurrences of "hello" in the list stored at list. =0 means all
      values.each do |val|
        @@redis.lrem key, 0, val #deletes all occurences of val
      end
    end

    def entry_exist?(key)
      @@redis.exists key
    end

    def find_value(key)
      type = @@redis.type key
      return @@redis.hgetall key if type == "hash"
      if type == "list"
      length = @@redis.llen key
      return @@redis.lrange key, 0, length-1 if length > 0
      return nil
      end
      return @@redis.get key if type == "string"
      #We don't use set or sorted set, so return nil
      return nil
    end

    #Key_values should be hash? I hope that *key_string when one string is used returns array, if not, .length
    #will return nonsense
    def save_string_entries(*key_string, overwrite)
      #controls that key_string has %2 == 0?
      keys_only = []
      strings_only = []
      (key_string.length).times do |x|
        keys_only << key_string[x] if x%2 == 0
        strings_only << key_string[x] if x%2 != 0
      end
      if overwrite
        keys_only.each_with_index do |key, index|
          @@redis.set key, strings_only[index]
        end
      else
        keys_only.each_with_index do |key, index|
          @@redis.set key, strings_only[index] unless @@redis.exists key
        end
      end
    end
  end
end