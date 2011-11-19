===ABOUT
This program represents a proof of concept for red2xml project. It consist of database interface
for Redis, XML transformer for saving/loading xml parts to database and DOM elements.

===INSTALLATION
To use this project correctly, you have to download and start Redis instance. Redis doesn't have official
binaries for Windows, but i have found pretty stable and verified binaries here:
https://github.com/dmajkic/redis/downloads
I have tested newest version 2.4.2
For nokogiri it is needed to install gem nokogiri on windows, it should be enough to just:
gem install nokogiri
But it does not work yet correctly, for detailed info:
http://nokogiri.org/tutorials/installing_nokogiri.html

===OTHER
Project uses ruby client for Redis called redis-rb which can be found in lib folder, you can find details
about it here:
http://redis-rb.keyvalue.org/v2.2.0/
All callings are based on official documentation of Redis, looks really promising. The list of commands can
be seen here:
http://redis.io/commands#
