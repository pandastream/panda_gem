require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'timecop'

describe Panda do
  before(:each) do
    new_time = Time.utc(2010, 1, 12, 1, 0, 0)
    Timecop.freeze(new_time)
  end
  
  describe "when not connected" do
    
    ["get", "post", "put", "delete"].each do |method|
      it "should raise error for #{method}" do
        lambda {
          Panda.send(method, nil, nil)
        }.should raise_error(Panda::ConfigurationError, "Panda is not configured!")
      end
    end
    
  end

  describe "root configuration with hash" do
    it "should not fail is access_key and secret_key are given" do
      proc do
        Panda.configure({:access_key => "bar", :secret_key => "baz"})
      end.should_not raise_error(Panda::ConfigurationError)
    end

    it "should fail if access_key or secret_key are missing" do
      proc do
        Panda.configure({:secret_key => "baz"})
      end.should raise_error(Panda::ConfigurationError)
      proc do
        Panda.configure({:access_key => "bar"})
      end.should raise_error(Panda::ConfigurationError)
      proc do
        Panda.configure({})
      end.should raise_error(Panda::ConfigurationError)
    end
  end

  describe "root configuration with block" do
    it "should not fail is access_key and secret_key are given" do
      proc do
        Panda.configure do
          access_key "bar"
          secret_key "baz"
        end
      end.should_not raise_error(Panda::ConfigurationError)
    end

    it "should fail if access_key or secret_key are missing" do
      proc do
        Panda.configure do
          secret_key "baz"
        end
      end.should raise_error(Panda::ConfigurationError)
      proc do
        Panda.configure do
          access_key "bar"
        end
      end.should raise_error(Panda::ConfigurationError)
      proc do
        Panda.configure do
        end
      end.should raise_error(Panda::ConfigurationError)
    end
  end

  shared_examples_for "Connected" do

    it "should make get request with signed request to panda server" do
      stub_http_request(:get, "http://myapihost:85/v2/videos?access_key=my_access_key&cloud_id=my_cloud_id&signature=kAiCpkP52a2XKISJjRCBWzWCN5CaeLK3Nj1AT25S/Go=&timestamp=2010-01-12T01%3A00%3A00.000000Z").to_return(:body => "{\"abc\":\"d\"}")
      @panda.get("/videos").should == {'abc' => 'd'}
    end

    it "should create a signed version of the parameters" do
      signed_params = @panda.signed_params('POST',
                                           '/videos.json',
                                           {"param1" => 'one', "param2" => 'two'}
                                           )
      signed_params.should == {
        'access_key' => "my_access_key",
        'timestamp' => "2010-01-12T01:00:00.000000Z",
        'cloud_id' => 'my_cloud_id',
        'signature' => '/Yu4CqImbYNXWwpNSIfHzdWeMsR5J7O6tfbSHXQO0aA=',
        'param1' => 'one',
        'param2' => 'two'
      }
    end

    it "should create a signed version of the parameters without additional arguments" do
      @panda.signed_params('POST', '/videos.json').should == {
        'access_key' => "my_access_key",
        'timestamp' => "2010-01-12T01:00:00.000000Z",
        'cloud_id' => 'my_cloud_id',
        'signature' => 'QpQQm0guSLSEXmQ+EP2qnKT0av5llLWBUylEk9NEStU='
      }
    end


    it "should create a signed version of the parameters and difficult characters" do
      signed_params = @panda.signed_params('POST',
                                           '/videos.json',
                                           {"tilde" => '~', "space" => ' '}
                                           )
      signed_params.should == {
        'access_key' => "my_access_key",
        'timestamp' => "2010-01-12T01:00:00.000000Z",
        'cloud_id' => 'my_cloud_id',
        'signature' => 'v7++pgmzztwOWzZ+MoflgD1TT8Jxnqzl1v8gNnEbhX8=',
        'tilde' => '~',
        'space' => ' '
      }
    end
    
    
    it "should not include file inside the signature" do
      @panda.signed_params('POST', '/videos.json', { "file" => "my_file" }).should == {
        'access_key' => "my_access_key",
        'timestamp' => "2010-01-12T01:00:00.000000Z",
        'cloud_id' => 'my_cloud_id',
        'signature' => 'QpQQm0guSLSEXmQ+EP2qnKT0av5llLWBUylEk9NEStU=',
        'file' => "my_file"
      }
    end

    it "should stringify keys" do
      @panda.signed_params('POST', '/videos.json', { :file => "symbol_key" }).should == {
        'access_key' => "my_access_key",
        'timestamp' => "2010-01-12T01:00:00.000000Z",
        'cloud_id' => 'my_cloud_id',
        'signature' => 'QpQQm0guSLSEXmQ+EP2qnKT0av5llLWBUylEk9NEStU=',
        'file' => "symbol_key"
      }
    end
  end
    
  describe "Panda.connect " do
    before(:each) do
      @panda = Panda.connect!({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id'})
    end
   it_should_behave_like "Connected"
  end

  describe "Panda.connect with symbols" do
    before(:each) do
      @panda = Panda.connect!({:access_key => "my_access_key", :secret_key => "my_secret_key", :api_host => "myapihost", :api_port => 85, :cloud_id => 'my_cloud_id'})
    end
    
   it_should_behave_like "Connected"
  end
  
  describe "Panda::Connection.new" do
     before(:each) do
       @panda = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id'})
     end
    it_should_behave_like "Connected"
  end
  
  describe "Using hash as a return format" do
    
    before(:each) do
      @panda = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })
    end
    
    it "should make get request" do
      stub_http_request(:get, "http://myapihost:85/v2/videos?access_key=my_access_key&cloud_id=my_cloud_id&signature=kAiCpkP52a2XKISJjRCBWzWCN5CaeLK3Nj1AT25S/Go=&timestamp=2010-01-12T01%3A00%3A00.000000Z").to_return(:body => "{\"key\":\"value\"}")
      @panda.get("/videos").should == {'key' => 'value'}
    end
    
  end
  
  # describe "ActiveSupport::JSON parsing" do
  # 
  #   it "should use active support if it has been defined and if restclient is used " do
  #     @panda = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })
  #     Panda.adapter = 'restclient'
  #     
  #     stub_http_request(:get, "http://myapihost:85/v2/videos?access_key=my_access_key&cloud_id=my_cloud_id&signature=DYpg2K6d7kGo%2FuWPO%2FaQgtQmY3BPtFEtQgdQhVe8teM%3D&timestamp=2010-01-12T01%3A00%3A00.000000Z").to_return(:body => "abc")
  # 
  # 
  #     module ActiveSupport
  #       class JSON; end
  #     end
  # 
  #     ActiveSupport::JSON.should_receive(:decode).with("abc").and_return("blah")
  #     @panda.get("/videos").should == "blah"
  #     
  #     Object.send :remove_const, :ActiveSupport
  #   end
  # end
  
  describe "parsing" do
    it "should raise an error if the response is not JSON parsable" do
      @connection = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })
      
      stub_http_request(:get, //).to_return(:body => "blahblah")
            
      lambda {
        @connection.get("/fake")
      }.should raise_error(Panda::ServiceNotAvailable)
    end
  end

end
