require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Video do
  before(:each) do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}"
    stub_http_request(:get, /http:\/\/api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)

    Panda.configure do |c|
      c.access_key = "my_access_key"
      c.secret_key = "my_secret_key"
      c.api_host = "api.example.com"
      c.cloud_id = 'my_cloud_id'
      c.api_port = 85
    end
    
  end

  describe "using a cloud" do
    before(:each) do
       cloud_json = "{\"s3_videos_bucket\":\"my_bucket1\",\"id\":\"cloud1\"}"
        stub_http_request(:get, /api.example.com:85\/v2\/clouds\/cloud1.json/).
          to_return(:body => cloud_json)
        @cloud = Panda::Cloud.find "cloud1"
    end
    
    it "should find all videos" do
      videos_json = "[{\"source_url\":\"my_source_url\",\"id\":\"123\"}]"
      stub_http_request(:get, /api.example.com:85\/v2\/videos.json/).
        to_return(:body => videos_json)
      @cloud.videos.first.id.should == "123"
    end
    
    it "should find all videos with params" do
      videos_json = "[{\"source_url\":\"my_source_url\",\"id\":\"134\"}]"
      stub_http_request(:get, /api.example.com:85\/v2\/videos.json/).
        with{|r| r.uri.query =~ /status=success/}.
          to_return(:body => videos_json)
      videos = @cloud.videos.all(:status => "success")
      videos.first.id.should == "134"
    end

    it "should find a video by id" do
      video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
      stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
        to_return(:body => video_json)
      video = @cloud.videos.find "123"
      video.id.should == "123"
    end

    it "should find all video with params" do
      videos_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
      stub_http_request(:post, /api.example.com:85\/v2\/videos.json/).
        to_return(:body => videos_json)
      @cloud.videos.create(:source_url => "my_source_url")
    end    
    
  end
end