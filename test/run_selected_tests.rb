require "test/unit"

Dir["./test_transformer/*.rb"].each {|file| require file }
Dir["./test_base_interface/*.rb"].each {|file| require file }

#Note that if we want to run all test files (test_*.rb) in a given folder, we can use
#command "testrb folder" in command line and all test files will be processed.

#If there is a need to some special processing before whole testsuite, we can do it this way

#require 'test/first_tester'
#require 'test/second_tester'
#require 'test/third_tester'

#class TS_MyTestSuite < Test::Unit::TestSuite
#  def self.suite
#    result = self.new(self.class.name)
#    result << FirstTester.suite
#    result << SecondTester.suite
#    result << ThirdTester.suite
#    return result
#  end

#  def setup
#    server.start
#  end

#  def teardown
#    server.stop
#  end

#  def run(*args)
#    setup
#    super
#    teardown
#  end
#end

#Test::Unit::UI::Console::TestRunner.run(TS_MyTestSuite)


#Also if we want to run some code before and after each test case (above code runs setup and teardown before and
#after ALL test cases), we can use static methods:

#class TestKeyBuilder < Test::Unit::TestCase
  
  #def setup()
  #  #code here will execute before each test (each test method)
  #end
  
  #class << self
    #def setup()
      #codehere will execute before all test methods in this case
    #end
  #end
#end
