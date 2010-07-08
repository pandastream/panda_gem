require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Video do
  before(:each) do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}"
    stub_http_request(:get, /http:\/\/myapihost:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)

    Panda.configure do |c|
      c.access_key = "my_access_key"
      c.secret_key = "my_secret_key"
      c.api_host = "myapihost"
      c.cloud_id = 'my_cloud_id'
      c.api_port = 85
    end
    
  end

  it "should find a cloud" do
    
   
  end
  
  
  describe "using a cloud" do
    before(:each) do
       cloud_json = "{\"s3_videos_bucket\":\"my_bucket1\",\"id\":\"cloud1\"}"
        stub_http_request(:get, /http:\/\/myapihost:85\/v2\/clouds\/cloud1.json/).
          to_return(:body => cloud_json)
        @cloud = Panda::Cloud.find "cloud1"
    end
    
    it "should find all video" do
      videos_json = "[{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}]"
      stub_http_request(:get, /myapihost:85\/v2\/videos.json/).to_return(:body => videos_json)
      
      @cloud.videos.first.id.should == "123"
    end
    
    
    it "should find all video with params" do
      videos_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"134\"}"
      stub_http_request(:get, /myapihost:85\/v2\/videos\/134.json/).to_return(:body => videos_json)
      video = @cloud.videos.find "134"
      video.id.should == "134"
    end
    
    
    it "should find all video with params" do
      videos_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}"
      stub_http_request(:post, /myapihost:85\/v2\/videos.json/).to_return(:body => videos_json)
      @cloud.videos.create "123"
    end    
    
  end
end