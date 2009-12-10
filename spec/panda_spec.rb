require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda do
  before(:each) do
    FakeWeb.allow_net_connect = false
    Panda.connect!({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myapihost", "api_port" => 85 })
    Time.stub!(:now).and_return(mock("time", :iso8601 => "2009-11-04T17:54:11+00:00"))
  end
  
  
  it "should make get request with signed request to panda server" do
    FakeWeb.register_uri(:get, "http://myapihost:85/v2/videos?timestamp=2009-11-04T17%3A54%3A11%2B00%3A00&signature=w5mqmay%2Fodw4gMDVVRLBsjXPwrUW8mTkjh19fJJ%2FAbM%3D&access_key=my_access_key", :body => "abc")
    Panda.get("/videos").should == "abc"
  end

  it "should make delete request with signed request to panda server" do
    FakeWeb.register_uri(:delete, "http://myapihost:85/v2/videos/1?timestamp=2009-11-04T17%3A54%3A11%2B00%3A00&signature=3abNswOMDFM9VQeS0nkK%2FkKKIA%2Fl8S27gAKQLXUrLSQ%3D&access_key=my_access_key", :query => {})
    Panda.delete("/videos/1").should
    FakeWeb.should have_requested(:delete, "http://myapihost:85/v2/videos/1?timestamp=2009-11-04T17%3A54%3A11%2B00%3A00&signature=3abNswOMDFM9VQeS0nkK%2FkKKIA%2Fl8S27gAKQLXUrLSQ%3D&access_key=my_access_key")
  end
  

end
