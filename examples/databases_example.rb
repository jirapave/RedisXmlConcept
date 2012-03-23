require_relative "../lib/redxml"

# First we have to create database, if database already exist, it is just retrieved
db_first = XMLDBApi::RedDatabase.new("first")

# Now we have to register database into database manager so it can delegate our future
# tasks onto those databases.
XMLDBApi::DatabaseManager.register_database(db_first)

db_second = XMLDBApi::RedDatabase.new("second")

# Now we have to databases registered, "first" and "second"
XMLDBApi::DatabaseManager.register_database(db_second)

# Well we don't need database "first" anymore so we will deregister that db
XMLDBApi::DatabaseManager.deregister_database(db_first)

# We would like to obtain our registered database back
db = XMLDBApi::DatabaseManager.get_database("xmldb:second")
# Or full URI
db = XMLDBApi::DatabaseManager.get_database("xmldb:second://some/collections")