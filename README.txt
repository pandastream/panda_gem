gem sources -a http://gems.github.com (you only have to do this once)
sudo gem install dctanner-panda_gem

require 'lib/panda.rb'
Panda.connect!('access_key', 'secret_key', 'localhost', 5678)
Panda.get('/videos')
