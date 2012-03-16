require "test/unit"
if File.basename($0) == "#{File.basename(__FILE__)}"
  require_relative "../../lib/redxml.rb"
else
  require "redxml"
end

class TestDBInterface < Test::Unit::TestCase
  
  def setup
    DBInit.init_database
    @db = BaseInterface::DBInterface.instance
  end
  
  def test_add_to_hash
    hash = %w(field-1 value-1 field-2 value-2)
    #Add to hash, overwrite all
    @db.add_to_hash "write", hash, true
    result_hash = @db.find_value "write"
    assert_equal(true, result_hash.length == 2)
    assert_equal(true, result_hash["field-1"] == "value-1")
    @db.add_to_hash "write", ["field-1", "different"], false
    result_hash = @db.find_value "write"
    assert_equal(true, result_hash["field-1"] == "value-1")
    @db.add_to_hash "write", ["field-1", "different"], true
    result_hash = @db.find_value "write"
    assert_equal(true, result_hash["field-1"] != "value-1")
  end
  
  def test_add_to_hash_ne
    @db.add_to_hash_ne "laila", "aaa", "1"
    result = @db.find_value "laila"
    assert_equal(true, result["aaa"] == "1")
    @db.add_to_hash_ne "laila", "aaa", "2"
    assert_equal(true, result["aaa"] == "1")
  end
  
  def test_increment_hash
    @db.increment_hash "hash", "field", 1
    @db.increment_hash "hash", "field", 1
    result_hash = @db.find_value "hash"
    assert_equal(true, result_hash["field"] == "2")
    @db.increment_hash "hash", "field", 5
    result_hash = @db.find_value "hash"
    assert_equal(true, result_hash["field"] == "7")
    @db.increment_hash "hash", "field", -3
    result_hash = @db.find_value "hash"
    assert_equal(true, result_hash["field"] == "4")
  end
  
  def test_delete_from_hash
    result_hash = @db.find_value "hash"
    assert_equal(true, result_hash["field-1"] == "value-1")
    @db.delete_from_hash "hash", ["field-1"]
    result_hash = @db.find_value "hash"
    assert_equal(true, result_hash["field-1"] == nil)
    @db.delete_from_hash "hash", ["field-2", "field-3"]
    result_hash = @db.find_value "hash"
    assert_equal(true, result_hash.length == 1)
    assert_equal(true, result_hash["field-2"] == nil)
    assert_equal(true, result_hash["field-3"] == nil)
    @db.delete_from_hash "hash", ["field-4"]
    result_hash = @db.find_value "hash"
    assert_equal(true, result_hash == nil)
  end
  
  def test_get_hash_value
    result = @db.get_hash_value "hash", "field-1"
    assert_equal(true, result == "value-1")
    result = @db.get_hash_value "hash", "non-existent"
    assert_equal(true, result == nil)
  end
  
  def test_get_all_hash_values
    result = @db.get_all_hash_values "hash"
    assert_equal(true, result.include?("value-1") == true)
    assert_equal(true, result.include?("field-1") == false)
    assert_equal(true, result.length == 4)
    result = @db.get_all_hash_values "non-existent"
    assert_equal(true, result.length == 0)
  end
  
  def test_get_all_hash_fields
    result = @db.get_all_hash_fields "hash"
    assert_equal(true, result.include?("value-1") == false)
    assert_equal(true, result.include?("field-1") == true)
    assert_equal(true, result.length == 4)
    result = @db.get_all_hash_fields "non-existent"
    assert_equal(true, result.length == 0)
  end
  
  def test_hash_value_exist?
    assert_equal(true, @db.hash_value_exist?("hash", "field-1") == true)
    assert_equal(true, @db.hash_value_exist?("hash", "field-22") == false)
    assert_equal(true, @db.hash_value_exist?("non-existent", "field-1") == false)
  end
  
  def test_add_to_list
    @db.add_to_list "laila", ["1"]
    @db.add_to_list "laila", ["2", "3"]
    result_hash = @db.find_value "laila"
    assert_equal(true, result_hash.length == 3)
    assert_equal(true, result_hash[1] == "2")
  end
  
  def test_delete_from_list
    @db.add_to_list "laila", ["2", "3", "4", "5", "2", "3", "2", "6"]
    @db.delete_from_list "laila", ["2"]
    result = @db.find_value "laila"
    assert_equal(true, result.length == 5)
    @db.delete_from_list "laila", ["3", "6"]
    result = @db.find_value "laila"
    assert_equal(true, result.length == 2)
    assert_equal(true, result[0] == "4")
  end
  
  def test_increment_string
    @db.increment_string "laila"
    @db.increment_string "laila"
    result = @db.find_value "laila"
    assert_equal(true, result == "2")
  end
  
  def test_decrement_string
    @db.increment_string "laila"
    @db.increment_string "laila"
    @db.increment_string "laila"
    @db.increment_string "laila"
    result = @db.find_value "laila"
    assert_equal(true, result == "4")
    @db.decrement_string "laila"
    result = @db.find_value "laila"
    assert_equal(true, result == "3")
    @db.decrement_string "laila"
    @db.decrement_string "laila"
    @db.decrement_string "laila"
    @db.decrement_string "laila"
    result = @db.find_value "laila"
    assert_equal(true, result == "-1")
  end
  
  def test_find_keys
    @db.increment_string "laila"
    @db.increment_string "lanka"
    @db.increment_string "america"
    @db.increment_string "2aba"
    @db.increment_string "3bbb"
    @db.increment_string "4cbc"
    result = @db.find_keys "l*"
    assert_equal(true, result.length == 2)
    result = @db.find_keys "*i*a"
    assert_equal(true, result.length == 2)
    result = @db.find_keys "??[b]?"
    assert_equal(true, result.length == 3)
  end
  
  def test_save_hash_entries
    insert = {"aaa" => "1", "bbb" => "2", "ccc" => "3"}
    @db.save_hash_entries insert, true
    result = @db.find_value "aaa"
    assert_equal(true, result == "1")
    result = @db.find_value "bbb"
    assert_equal(true, result == "2")
  end
  
  def test_save_string_entries
    insert = %w(aaa 1 bbb 2 ccc 3)
    @db.save_string_entries *insert, true
    result = @db.find_value "aaa"
    assert_equal(true, result == "1")
    result = @db.find_value "bbb"
    assert_equal(true, result == "2")
    @db.save_string_entries "eee", "5", true
    result = @db.find_value "eee"
    assert_equal(true, result == "5")
  end
  
  def test_delete_entries
    @db.delete_entries ["hash"]
    result = @db.find_value "hash"
    assert_equal(true, result == nil)
    @db.increment_string "laila"
    @db.increment_string "lenier"
    @db.delete_entries ["laila", "lenier"]
    result = @db.find_value "lenier"
    assert_equal(true, result == nil)
  end
  
  def test_entry_exist?
    assert_equal(true, @db.entry_exist?("hash") == true)
    @db.delete_entries ["hash"]
    assert_equal(true, @db.entry_exist?("hash") == false)
  end
  
  def test_find_value
    result = @db.find_value "hash"
    assert_equal(true, result.instance_of?(Hash) == true)
    assert_equal(true, result["field-2"] == "value-2")
    @db.add_to_list "list", ["aaa", "bbb"]
    result = @db.find_value "list"
    assert_equal(true, result.instance_of?(Array) == true)
    assert_equal(true, result[0] == "aaa")
    @db.save_string_entries "string", "something", true
    result = @db.find_value "string"
    assert_equal(true, result.instance_of?(String) == true)
    assert_equal(true, result == "something")
  end
  
end