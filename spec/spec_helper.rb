$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'panda'
require 'spec'
require 'spec/autorun'

require 'webmock/rspec'
include WebMock


Spec::Runner.configure do |config|
  config.before(:each) do
    Panda.connection = nil
    Panda.cloud = nil
    Time.stub!(:now).and_return(mock("time", :iso8601 => "2009-11-04T17:54:11+00:00"))
  end
end
