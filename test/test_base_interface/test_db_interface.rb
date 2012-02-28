require_relative "../../lib/base_interface/db_interface"
require "test/unit"

class TestDBInterface < Test::Unit::TestCase
  def test_add_to_hash
    #This will work here...but it is dangerous! $0 now refers to path to this file, so
    #File.dirname($0) + '/../lib/' still works (same for main.rb), but if this file would
    #ever be in some other folder..it will not work
    db = BaseInterface::DBInterface.instance

    hash = %w(field-1 value-1 field-2 value-2)
    #Add to hash, overwrite all
    db.add_to_hash "hash", *hash, true
    result_hash = db.find_value "hash"
    assert_equal(true, result_hash.length == 2)
  end
end