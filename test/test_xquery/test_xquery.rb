require_relative "../../lib/red_xml_api/environment_manager"
require_relative "../../lib/xquery_module/xquery/xquery_controller"
require_relative "../../lib/xml/node"
require "rubygems"
require "nokogiri"
require "test/unit"

#missing in other files
require_relative "../../lib/transformer/exceptions"
# require_relative "../../lib/transformer/document_service"


module XQuery
  class TestXQuery < Test::Unit::TestCase
    
    class TestCase
      
      attr_reader :query, :results
      
      def initialize(query, results)
        @query = query
        @results = results
      end
    end
    
    TEST_CASES = [
      TestCase.new("for $prod in doc(  \"catalog.xml\"  )/catalog/product[position()<=3]  where $prod/@dept<=\"ACC\" order by $prod/name return <elem>$prod/name</elem>",
        ["<elem><name language=\"en\">Deluxe Travel Bag</name></elem>", "<elem><name language=\"en\">Floppy Sun Hat</name></elem>"]),
    ]
    
    def setup
      @env_name = "env_test"
      @coll_name = "coll_test"
      file_path = "../../bin/catalog.xml"
      env_manager = RedXmlApi::EnvironmentManager.new()
      env = env_manager.create_environment(@env_name)
      if(env == nil)
        env = RedXmlApi::Environment.new(@env_name)
      end
      coll = env.create_collection(@coll_name)
      if(coll == nil)
        coll = RedXmlApi::Collection.new(@env_name, @coll_name)
      end
      begin
        coll.save_document(file_path)
      rescue Transformer::MappingException
        puts "ok, document exists"
      end
    end
    
    
    def test_xpath
      
      xquery_controller = XQuery::XQueryController.new(@env_name, @coll_name)
      
      TEST_CASES.each_with_index { |test_case, index|
        new_results = xquery_controller.get_results(test_case.query)
        right_results = test_case.results
        
        assert_equal(right_results.length, new_results.length, "for query: #{test_case.query}, result count not the same")
        
        right_results.each_with_index { |right_result, index|
          new_result = new_results[index]
          if(new_result.kind_of?(XML::Node))
            new_result = new_result.to_stripped_s
          end
          assert_equal(right_result, new_result, "for query: #{test_case.query}, results are not the same")
        }
        
        puts "test #{index+1}/#{TEST_CASES.length} ok"
        
      }
      
    end
    
  end
end