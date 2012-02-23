require_relative "../lib/base_interface/db_interface"

class DBInit
  ENV_MAP_SIGN = "environments"
  COLL_MAP_SIGN = "collections"
  DOC_MAP_SIGN = "documents"
  
  ELEM_MAP_KEY = "1:2:3<emapping"
  ATTR_MAP_KEY = "1:2:3<amapping"
  
  CONTENT_KEY = "1:2:3<content"
  
  def self.init_database
    db = BaseInterface::DBInterface.instance
    #Create environment {"env" => 1}, collection {"coll" => 1} and file {"test.xml" => 1}
    #All will be prepared by hand, because usage of KeyBuilder and other classes would compromite
    #tests
    
    #Following XML document will be saved
    #<catalog encoding="UTF-8" version="1.0" standalone="YES">
    #  <product dept="WMN" language="cz">
    #    <number>557</number>
    #    <name language="en">Fleece Pullover</name>
    #    <colorChoices>navy black</colorChoices>
    #  </product>
    #</catalog>
   
    field_values = []
    field_values << "name" << "test.xml"
    field_values << "version" << "1.0"
    field_values << "encoding" << "UTF-8"
    field_values << "standalone" << "YES"
    field_values << "root" << "1" #root is id not a name
    
    #Now we willl save mapping of elements and attributes
    elements = %w(catalog 1 product 2 number 3 name 4 colorChoices 5)
    attributes = %w(dept 1 language 2)
    
    content_arr = []
    content_arr << "1" << "1:2>1|1:2>2"
    content_arr << "1:2>1" << "1:2>1:3>1|1:2>1:4>1|1:2>1:5>1" #first product
    content_arr << "1:2>2" << "1:2>2:3>1|1:2>2:4>1|1:2>2:5>1" #second product
    content_arr << "1:2>1:3>1" << "1:2>1:3>1>t>1" 
    content_arr << "1:2>1:4>1" << "1:2>1:4>1>t>1"
    content_arr << "1:2>1:5>1" << "1:2>1:5>1>t>1"
    content_arr << "1:2>1:3>1>t>1" << "557"
    content_arr << "1:2>1:4>1" << "Fleece Pullover"
    content_arr << "1:2>1:5>1" << "navy black"
    #Attributes content
    content_arr << "1:2>1<a" << "1\"WMN\"2\"cz" 
    content_arr << "1:2>1:4>1" << "2\"en"
    
    db.commit_after do
      db.add_to_hash(ENV_MAP_SIGN, ["env", "1"], true)
      db.add_to_hash("1:#{COLL_MAP_SIGN}", ["coll", "2"], true)
      db.add_to_hash("1:2:#{DOC_MAP_SIGN}", ["test.xml", "3"], true)
      db.add_to_hash(ELEM_MAP_KEY, elements, true)
      db.add_to_hash(ELEM_MAP_KEY, ["<iterator>", "5"], true)
      db.add_to_hash(ATTR_MAP_KEY, attributes, true)
      db.add_to_hash(ATTR_MAP_KEY, ["<iterator>", "2"], true)
      db.add_to_hash(CONTENT_KEY, content_arr, true)
    end
  end
end