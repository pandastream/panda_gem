require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Encoding do
  before(:each) do

    Panda.configure do
      access_key "my_access_key"
      secret_key "my_secret_key"
      api_host "api.example.com"
      cloud_id 'my_cloud_id'
      api_port 85
    end
    
  end
  
  it "should find by video_id" do
    encoding_json = "[{\"abc\":\"efg\",\"id\":456}]"
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).
      to_return(:body => encoding_json)
    Panda::Encoding.find_all_by_video_id("123").first.id.should == 456
  end

  it "should create an encoding using instance method" do
    encoding_json = "{\"source_url\":\"my_source_url\",\"id\":\"456\"}"
    stub_http_request(:post, /api.example.com:85\/v2\/encodings.json/).
      with(:body => /source_url=my_source_url/).
        to_return(:body => encoding_json)
    
    encoding = Panda::Encoding.new(:source_url => "my_source_url", :video_id => "123")
    encoding.create.should == true
    encoding.id.should == "456" 
  end
  
  it "should find by encoding_id" do
    encoding_json = "{\"abc\":\"efg\",\"id\":\"456\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/encodings\/456.json/).
      to_return(:body => encoding_json)
    encoding = Panda::Encoding.find("456")
    encoding.id.should == "456"
  end
    
  it "should find by the video through the association" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    encoding_json = "{\"abc\":\"efg\",\"id\":\"456\", \"video_id\":\"123\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/encodings\/456.json/).
      to_return(:body => encoding_json)
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)
    encoding = Panda::Encoding.find("456")
    encoding.video.id.should == "123"
    encoding.id.should == "456"
  end
  
  it "should filter on find" do
    encoding_json = "[{\"source_url\":\"my_source_url\",\"id\":\"456\"}]"
    
    stub_http_request(:get, /api.example.com:85\/v2\/encodings.json/).
      with{|r| r.uri.query =~ /profile_name=my_profile/ && r.uri.query =~ /video_id=123/ }.
        to_return(:body => encoding_json)

    encodings = Panda::Encoding.all(:video_id => "123", :profile_name => "my_profile")
    encodings.first.id.should == "456"
  end
  
  it "should return the encoding url" do    
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\", \"url\":\"http://my_bucket.s3.amazonaws.com/\"}" 
    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)
    
    encoding = Panda::Encoding.new({:id => "456", :extname => ".ext", :path => "abc/panda", :status => 'success'})
    encoding.url.should == "http://my_bucket.s3.amazonaws.com/abc/panda.ext"
  end
  
  it "should generate a screenhost array" do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\", \"url\":\"http://my_bucket.s3.amazonaws.com/\"}" 
    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)

    encoding = Panda::Encoding.new({:id => "456", :extname => ".ext", :status => "success", :path => "abc/panda"})
    encoding.screenshots[0].should == "http://my_bucket.s3.amazonaws.com/abc/panda_1.jpg"
  end

  it "should generate a screenhost array" do
    encoding = Panda::Encoding.new({:id => "456", :extname => ".ext", :status => "fail"})
    encoding.screenshots.should == []
  end

  
  it "should create an encoding through the association" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    encoding_json = "{\"abc\":\"efg\",\"id\":\"456\", \"video_id\":\"123\", \"profile_id\":\"901\"}"

    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)

    stub_http_request(:post, /api.example.com:85\/v2\/encodings.json/).
        with{|r| r.body =~ /video_id=123/ && r.body =~ /profile_id=901/}.
          to_return(:body => encoding_json)

    video = Panda::Video.find("123")
    
    encoding = video.encodings.create(:profile_id => "901")
    encoding.id.should == "456"
    encoding.profile_id.should == "901"
  end
  
  it "should create an encoding through the association" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    encoding_json = "{\"abc\":\"efg\",\"id\":\"456\", \"video_id\":\"123\", \"profile_id\":\"901\"}"

    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)

    stub_http_request(:post, /api.example.com:85\/v2\/encodings.json/).
        with{|r| r.body =~ /video_id=123/ && r.body =~ /profile_id=901/}.
          to_return(:body => encoding_json)

    video = Panda::Video.find("123")
    
    encoding = video.encodings.create!(:profile_id => "901")
    encoding.id.should == "456"
    encoding.profile_id.should == "901"
  end
  
  
  it "should filter the profile name after triggering the request" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    encodings_1_json = "[{\"id\":\"456\", \"video_id\":\"123\", \"profile_name\":\"h264\"}]"
    encodings_2_json = "[{\"id\":\"789\", \"video_id\":\"123\", \"profile_name\":\"ogg\"}]"

    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)

    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).
      with{|r| r.uri.query =~ /profile_name=h264/ }.
          to_return(:body => encodings_1_json)

    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).
      with{|r| r.uri.query =~ /profile_name=ogg/ }.
          to_return(:body => encodings_2_json)

    video = Panda::Video.find("123")
    video.encodings.find_by_profile_name("h264").id.should == "456"
    video.encodings.find_by_profile_name("ogg").id.should == "789"
  end

  it "should create an encoding through the association" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    encodings_json = "[{\"abc\":\"efg\",\"id\":\"456\", \"video_id\":\"123\", \"profile_id\":\"901\"}]"
    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)
    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).
        with{|r| r.uri.query =~ /profile_id=901/}.
          to_return(:body => encodings_json)

    video = Panda::Video.find("123")
    encodings = video.encodings.all(:profile_id => "901")
    encodings.first.id = "456"
  end
  
  it "should create an encoding through the association" do
    video_json = "{\"source_url\":\"my_source_url\",\"id\":\"123\"}"
    encodings_json = "[{\"abc\":\"efg\",\"id\":\"456\", \"video_id\":\"123\", \"profile_id\":\"901\"}]"
    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123.json/).
      to_return(:body => video_json)
    
    stub_http_request(:get, /api.example.com:85\/v2\/videos\/123\/encodings.json/).
        with{|r| r.uri.query =~ /profile_id=901/}.
          to_return(:body => encodings_json)

    video = Panda::Video.find("123")
    encodings = video.encodings.profile("901")
    encodings.first.id = "456"
  end
  
  it "should filter encodings specifying video and status as a method" do
    encoding_json = "[{\"source_url\":\"my_source_url\",\"id\":\"456\"}]"
    
    stub_http_request(:get, /api.example.com:85\/v2\/encodings.json/).
      with{|r| r.uri.query =~ /status=success/ && r.uri.query =~ /video_id=123/ }.
        to_return(:body => encoding_json)

    encodings = Panda::Encoding.video(123).status("success").all
    encodings.first.id.should == "456"    
  end
  
  it "should filter encodings specifying video and status as a method" do
    encoding_json = "[{\"source_url\":\"my_source_url\",\"id\":\"456\"}]"
    
    stub_http_request(:get, /api.example.com:85\/v2\/encodings.json/).
      with{|r| r.uri.query =~ /profile_id=prof_1/ && r.uri.query =~ /video_id=123/ }.
        to_return(:body => encoding_json)

    encodings = Panda::Encoding.video(123).profile("prof_1").all
    encodings.first.id.should == "456"
  end
  
  it "should filter encodings specifying video and profile id as a method" do
    encoding_json = "[{\"source_url\":\"my_source_url\",\"id\":\"456\"}]"
    
    stub_http_request(:get, /api.example.com:85\/v2\/encodings.json/).
      with{|r| r.uri.query =~ /profile_name=prof_name/ && r.uri.query =~ /video_id=123/ }.
        to_return(:body => encoding_json)

    encodings = Panda::Encoding.video(123).profile_name("prof_name").all
    encodings.first.id.should == "456"
  end
  
  it "should find an encoding" do
    encoding_json = "[{\"source_url\":\"my_source_url\",\"id\":\"456\"}]"
    stub_http_request(:get, /api.example.com:85\/v2\/encodings\/456.json/).
      to_return(:body => encoding_json)
    
    Panda::Encoding.find("456")
  end
  
  it "should tell if the encoding is success" do
    encoding = Panda::Encoding.new({:status => "success"})
    encoding.success?.should == true
    encoding.processing?.should == false
  end

  it "should tell if the encoding is success" do
    encoding = Panda::Encoding.new({:status => "processing"})
    encoding.success?.should == false
    encoding.processing?.should == true
  end

  it "should tell if the encoding is success" do
    encoding = Panda::Encoding.new({:status => "fail"})
    encoding.success?.should == false
    encoding.fail?.should == true
  end

  it "should return the most recent updated encoding" do
    video_json = "[{\"source_url\":\"url_panda.mp4\",\"id\":\"123\"}]"
    stub_http_request(:get, /api.example.com:85\/v2\/encodings.json/).
      with{|r| r.uri.query =~ /per_page=1/ }.
        to_return(:body => video_json)
    Panda::Encoding.first
  end

  it "should not delegate scope if the method do not really exist in the scope" do
    lambda {Panda::Encoding.reload}.should raise_error(NoMethodError)
    lambda {Panda::Encoding.each}.should raise_error(NoMethodError)
    lambda {Panda::Encoding.size}.should raise_error(NoMethodError)
  end
end
