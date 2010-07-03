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

  it "should create a encodings" do
    encoding_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"456\"}"
    stub_http_request(:post, /http:\/\/myapihost:85\/v2\/encodings.json/).
      with(:source_url =>"http://a.b.com/file.mp4").
        to_return(:body => encoding_json)
    
    encoding = Panda::Encoding.new(:source_url => "http://a.b.com/file.mp4", :video_id => "123")
    encoding.save.should == true
    encoding.id.should == "456" 
  end
  
  it "should find by encoding_id" do
    encoding_json = "{\"abc\":\"efg\",\"id\":\"456\"}"
    stub_http_request(:get, /myapihost:85\/v2\/encodings\/456.json/).to_return(:body => encoding_json)
    encoding = Panda::Encoding.find("456")
    encoding.id.should == "456"
  end
    
    
  it "should filter on find" do
    encoding_json = "[{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"456\"}]"
    
    stub_http_request(:get, /http:\/\/myapihost:85\/v2\/encodings.json/).
      with(:profile_name => "mp4").
        to_return(:body => encoding_json)
    
    encodings = Panda::Encoding.find_all_by(:video_id => "123", :profile_name => "my_profile")
    encodings.first.id.should == "456"
    
  end
end
