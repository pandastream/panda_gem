require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Cloud do
  
  describe "region" do
    it "should tell the region" do
      Panda.configure do
        access_key "my_access_key"
        secret_key "my_secret_key"
        api_host "api.pandastream.com"
        cloud_id 'my_cloud_id'
        api_port 85
      end
      
      Panda.cloud.region.should == "us"
      Panda.cloud.us?.should == true
    end
    
    it "should tell the region" do
      Panda.configure do |c|
        access_key "my_access_key"
        secret_key "my_secret_key"
        api_host "api.eu.pandastream.com"
        cloud_id 'my_cloud_id'
        api_port 85
      end
      
      Panda.cloud.region.should == "eu"
      Panda.cloud.eu?.should == true
    end
    
  end
  
  describe "Using configure bloc" do
    before(:each) do
      Panda.configure do
        access_key "my_access_key"
        secret_key "my_secret_key"
        api_host "api.example.com"
        cloud_id 'my_cloud_id'
        api_port 85
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
            with{|r| r.uri.query =~ /cloud_id=cloud1/}.
              to_return(:body => videos_json)

        @cloud.videos.first.id.should == "123"
      end
    
      it "should find all videos with params" do
        videos_json = "[{\"source_url\":\"my_source_url\",\"id\":\"134\"}]"
        stub_http_request(:get, /api.example.com:85\/v2\/videos.json/).
          with{|r| r.uri.query =~ /status=success/ && r.uri.query =~ /cloud_id=cloud1/}.
            to_return(:body => videos_json)
        videos = @cloud.videos.all(:status => "success")
        videos.first.id.should == "134"
      end

      it "should find a video by id" do
        video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
        stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
          with{|r| r.uri.query =~ /cloud_id=cloud1/}.
          to_return(:body => video_json)

        video = @cloud.videos.find "123"
        video.id.should == "123"
      end

      it "should create a video using cloud" do
        videos_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
        stub_http_request(:post, /api.example.com:85\/v2\/videos.json/).
          with{|r| r.body =~ /cloud_id=cloud1/}.
          to_return(:body => videos_json)
        @cloud.videos.create(:source_url => "my_source_url")
      end
    end
    
    describe "Using options on find" do
      
      it "should find a cloud" do
        cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}"
        stub_http_request(:get, /http:\/\/api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
          to_return(:body => cloud_json)
        
        @cloud = Panda::Cloud.find "my_cloud_id", {
          "access_key" => "my_access_key", 
          "secret_key" => "my_secret_key", 
          "api_host" => "api.example.com", 
          "api_port" => 85, 
          "format" => "json" 
        }
        
        @cloud.s3_videos_bucket.should == "my_bucket"
      end
    end
    
  end
end