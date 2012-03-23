require_relative "../lib/redxml"

db = XMLDBApi::RedDatabase.new("db_name")
XMLDBApi::DatabaseManager.register_database(db)

# First we would like to create our first collection so we can work further with her
coll = db.create_collection("root_collection")

# Now lets say that we want to get that collection again after some other work
coll = XMLDBApi::DatabaseManager.get_collection("xmldb:db_name://root_collection")

# Note URI is composed of mandatory prefix xmldb: followed by database name and than 
# path to collection

# Next we will create some other child collections
coll.create_child_collection("child-1")
coll.create_child_collection("child-2")

# We can also do that using plain XMLDB:API, but it's much longer, parameters can be found
# in documentation. Sometimes is is handy to have service alone.
service = coll.get_service("CollectionManagementService", "1.0")
service.create_collection("child-3")

# We have so many collections, lets delete one
coll.remove_child_collection("child-3")

# Or we can use service again
service.remove_collection("child-1")

# Now lets show some other basic functionality
coll = XMLDBApi::DatabaseManager.get_collection("xmldb:db_name://root_collection/child-2")
another = coll.create_child_collection("another")
coll = another.get_parent_collection
puts "names of child collections: #{coll.list_child_collections}"
new_name = coll.create_id
coll.create_child_collection(new_name)


