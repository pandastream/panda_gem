$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'panda'
require 'spec'
require 'spec/autorun'

require 'fakeweb'
require 'fakeweb_matcher'

Spec::Runner.configure do |config|
  
end
