require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Encoding do
  before(:each) do
    Time.stub!(:now).and_return(mock("time", :iso8601 => "2009-11-04T17:54:11+00:00"))

    Panda.configure do |c|
      c.access_key = "my_access_key"
      c.secret_key = "my_secret_key"
      c.api_host = "myapihost"
      c.cloud_id = 'my_cloud_id'
      c.api_port = 85
    end
    
  end
  
  
  it "should find by video_id" do
    encoding_json = "[{\"abc\":\"efg\",\"id\":456}]"
    
    stub_http_request(:get, /myapihost:85\/v2\/videos\/123\/encodings.json/).to_return(:body => encoding_json)
    
    Panda::Encoding.find_all_by_video_id("123").first.id.should == 456
    
  end
  
  
end
