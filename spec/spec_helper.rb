$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'panda'
require 'rspec'

require 'webmock/rspec'
include WebMock::API

def hputs(*args)
  puts ERB::Util.html_escape(args.join("\n")).gsub(/\r?\n/, '<br/>') + '<br/>'
end

RSpec.configure do |config|
  config.before(:each) do
    Panda.instance_variable_set("@connection", nil)
    Panda.instance_variable_set("@cloud", nil)
  end
end
