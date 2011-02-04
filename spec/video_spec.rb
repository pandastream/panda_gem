require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Video do
  before(:each) do
    
    Panda.configure do
      access_key "my_access_key"
      secret_key "my_secret_key"
      api_host "api.example.com"
      cloud_id 'my_cloud_id'
      api_port 85
    end
    
  end
  
  it "should create a video object" do
    v = Panda::Video.new({ :test => "abc" })
    v.test.should == "abc"
  end
  
  it "should tell video is new" do
    v = Panda::Video.new({ :id => "abc" })
    v.new?.should be_false
  end
  
  it "should not tell video is new" do
    v = Panda::Video.new({ :attr => "abc" })
    v.new?.should be_true
  end

  it "should find return all videos" do
    
    videos_json = "[{\"source_url\":\"my_source_url\",\"id\":111},{\"source_url\":\"http://a.b.com/file2.mp4\",\"id\":222}]"

    stub_http_request(:get, /api.example.com:85\/v2\/videos.json/).to_return(:body => videos_json)

    videos = Panda::Video.all
    videos.first.id.should == 111
    videos.first.source_url.should == "my_source_url"
      videos.size.should == 2
  end
  
  it "should find a videos having the correct id" do
    
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)

    video = Panda::Video.find("123")
    video.id.should == "123"
    video.source_url.should == "my_source_url"
  end
  
  it "should raise exception if id is nil" do
    
    lambda {
      Panda::Video.find(nil)
    }.should raise_error('find method requires a correct value')

  end
  
  it "should list all video's encodings" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    encodings_json = "[{\"abc\":\"my_source_url\",\"id\":\"456\"}]"
    
    encodings = [Panda::Encoding.new({:abc => "my_source_url", :id => "456"})]    

    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).to_return(:body => encodings_json)

    video = Panda::Video.find("123")
    video.encodings.first.attributes.should == encodings.first.attributes
  end
  
  it "should delete a video using class" do
    video_json = "{\"deleted\":\"ok\"}"
    stub_http_request(:delete, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)

    video = Panda::Video.new(:source_url => "my_source_url", :id => "123")
    video.cloud
    video.delete.should == true
  end
  
  it "should delete a video using instance" do
    video_json = "{\"deleted\":\"ok\"}"
    stub_http_request(:delete, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)

    Panda::Video.delete("123")
  end
  
  it "should have an error object if something goes wrong" do
    response = "{\"message\":\"no-abc\",\"error\":\"error-abc\"}"
    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/abc.json/).to_return(:body => response)
    
    lambda {
        Panda::Video.find "abc"
    }.should raise_error(Panda::APIError, "error-abc: no-abc")
  end
  
  it "should have an error object if something goes wrong" do
    response = "{\"message\":\"no-abc\",\"error\":\"error-abc\"}"
    
    stub_http_request(:put, /api.example.com:85\/v2\/profiles\/abc.json/).to_return(:body => response)
    
    obj = Panda::Profile.new(:id => "abc")
    original_attrs = obj.attributes
    obj.save
    
    obj.errors.size.should == 1
    obj.errors.first.to_s.should == "error-abc: no-abc"
    obj.attributes.should == original_attrs
    
  end
  
  it "should connect to eu" do


    Panda.configure do
      access_key "my_access_key"
      secret_key "my_secret_key"
      cloud_id 'my_cloud_id'
      region "eu"
    end
    
    stub_http_request(:get, /api.eu.pandastream.com:443/).
      to_return(:body => "{\"id\":\"123\"}")
    Panda::Video.find "123"
  end
  
  it "should connect to eu and trigger the request" do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}" 
    stub_http_request(:get, /api.eu.pandastream.com:80\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)

    Panda.configure do |c|
      c.access_key "my_access_key"
      c.secret_key "my_secret_key"
      c.cloud_id 'my_cloud_id'
      c.region  "eu"
    end
    
    stub_http_request(:get, /api.eu.pandastream.com:443/).
      to_return(:body => "{\"id\":\"123\"}")
    Panda::Video.find "123"
  end
  
  it "should use the correct connection" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"cloud1\"}"
    cloud2_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"cloud2\"}"

    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/cloud1.json/).
      to_return(:body => cloud_json)    
    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/cloud2.json/).
      to_return(:body => cloud2_json)

    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)          
    
    cloud = Panda::Cloud.new(:id => "cloud1")

    cloud2 = Panda::Cloud.new(:id => "cloud2")
    
    video = cloud.videos.find("123")
    video2 = cloud2.videos.find("123")
    
    video.cloud.id.should == "cloud1"
    video2.cloud.id.should == "cloud2"

    Panda::Video.cloud.id.should == "my_cloud_id"
  end
  
  it "should create a video using class method" do
    video_json = "{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}"
    
    stub_http_request(:post, /api.example.com:85\/v2\/videos.json/).
      with(:body => /source_url=url_panda.mp4/).
        to_return(:body => video_json)
    
    video = Panda::Video.create(:source_url => "url_panda.mp4")
    video.id.should == "123"
  end
  
  it "should create a video using class method and a block" do
    video_json = "{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}"
    
    stub_http_request(:post, /api.example.com:85\/v2\/videos.json/).
      with(:body => /source_url=url_panda.mp4/).
        to_return(:body => video_json)
    
    video = Panda::Video.create do |v|
      v.source_url = "url_panda.mp4"
    end
    
    video.id.should == "123"
  end
  
  it "should return a json on attributes" do
    video = Panda::Video.new(:attr => "value")
    video.to_json.should == video.attributes.to_json
  end
  
  it "should create an encoding using video scope" do
    encoding_json = "{\"source_url\":\"my_source_url\",\"id\":\"678\"}"
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)

    stub_http_request(:post, /api.example.com:85\/v2\/encodings.json/).
      with(:body => /profile_id=345/).
        to_return(:body => encoding_json)

    video = Panda::Video.find "123"
    encoding = video.encodings.create(:profile_id => "345")
    encoding.id.should == "678"
  end
  
  it "should not create a model having an id" do
    video = Panda::Video.new(:id => "abc")
    lambda {
      video.create
    }.should raise_error "Can't create attribute. Already have an id=abc"
  end
  
  it "should not create a model having an id" do
    lambda {
      Panda::Video.create(:id => "abc")
    }.should raise_error "Can't create attribute. Already have an id=abc"
  end
  
  it "should not call the request twice" do
    video_json = "{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    video = Panda::Video.find("123")

    encodings_json = "[{\"abc\":\"my_source_url\",\"id\":\"456\"}]"    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).to_return(:body => encodings_json)

    encodings = video.encodings
    encodings.first
    encodings.first
    
    WebMock.should have_requested(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).once
  end
  
  it 'should generate json of encodings' do
    video_json = "{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    video = Panda::Video.find("123")

    encodings_json = "[{\"abc\":\"my_source_url\",\"id\":\"456\"}]"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).to_return(:body => encodings_json)

    video.encodings.to_json.should == "[{\"abc\":\"my_source_url\",\"id\":\"456\",\"cloud_id\":\"my_cloud_id\"}]"
  end
  
  it "should return the video url" do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\", \"url\":\"http://my_bucket.s3.amazonaws.com/\"}" 
    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)
    
    video = Panda::Video.new({:id => "456", :extname => ".ext", :path => "abc/panda", :status => 'success'})
    video.url.should == "http://my_bucket.s3.amazonaws.com/abc/panda.ext"
  end
  
  it "should generate a screenhost array" do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\", \"url\":\"http://my_bucket.s3.amazonaws.com/\"}" 
    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)

    video = Panda::Video.new({:id => "456", :extname => ".ext", :status => "success", :path => "abc/panda"})
    video.screenshots[0].should == "http://my_bucket.s3.amazonaws.com/abc/panda_1.jpg"
  end
  
  it "should call the request if the scope has changed" do
    video_json = "{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    video = Panda::Video.find("123")

    encodings_json = "[{\"abc\":\"my_source_url\",\"id\":\"456\"}]"    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).to_return(:body => encodings_json)

    encodings = video.encodings.status("success")
    
    encodings.first
    encodings.last
    
    video.encodings.first
    
    WebMock.should have_requested(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).once
  end
  
  it "should not call the request twice" do
    video_json = "{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    video = Panda::Video.find("123")

    encodings_json = "[{\"abc\":\"my_source_url\",\"id\":\"456\"}]"    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).to_return(:body => encodings_json)

    encodings = video.encodings
    encodings.first.id.should == "456"
    encodings.reload
    
    WebMock.should have_requested(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).twice
  end

  it "should tell if the video is success" do
    encoding = Panda::Video.new({:status => "success"})
    encoding.success?.should == true
    encoding.processing?.should == false
  end

  it "should tell if the video is success" do
    encoding = Panda::Video.new({:status => "processing"})
    encoding.success?.should == false
    encoding.processing?.should == true
  end

  it "should tell if the video is success" do
    encoding = Panda::Video.new({:status => "fail"})
    encoding.success?.should == false
    encoding.fail?.should == true
  end
  
  it "should return the most recent updated video" do
    video_json = "[{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}]"
    stub_http_request(:get, /api.example.com:85\/v2\/videos.json/).
      with{|r| r.uri.query =~ /per_page=1/ }.
        to_return(:body => video_json)
    Panda::Video.first
  end

  it "should not delegate scope if the method do not really exist in the scope" do
    lambda {Panda::Video.reload}.should raise_error(NoMethodError)
    lambda {Panda::Video.each}.should raise_error(NoMethodError)
    lambda {Panda::Video.size}.should raise_error(NoMethodError)
  end
  
  it "should lazy load the cloud" do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}" 
    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)
    
      video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
      stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
        to_return(:body => video_json)
        
    video = Panda::Video.find "123"
    video.cloud.s3_videos_bucket.should == "my_bucket"
  end
end