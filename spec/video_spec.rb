require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Video do
  before(:each) do
    Time.stub!(:now).and_return(mock("time", :iso8601 => "2009-11-04T17:54:11+00:00"))
    
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}" 
    stub_http_request(:get, /http:\/\/myapihost:85\/v2\/clouds\/my_cloud_id.json/).to_return(:body => cloud_json)

    Panda.configure do |c|
      c.access_key = "my_access_key"
      c.secret_key = "my_secret_key"
      c.api_host = "myapihost"
      c.cloud_id = 'my_cloud_id'
      c.api_port = 85
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
    
    videos_json = "[{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":1},{\"source_url\":\"http://a.b.com/file2.mp4\",\"id\":2}]"

    stub_http_request(:get, /myapihost:85\/v2\/videos.json/).to_return(:body => videos_json)

    videos = Panda::Video.all
    videos.first.id.should == 1
    videos.first.source_url.should == "http://a.b.com/file.mp4"
    videos.size.should == 2
  end
  
  it "should find a videos having the correct id" do
    
    video_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /myapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)

    video = Panda::Video.find("123")
    video.id.should == "123"
    video.source_url.should == "http://a.b.com/file.mp4"
  end
  
  
  it "should list all video's encodings" do
    video_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}"
    encodings_json = "[{\"abc\":\"http://a.b.com/file.mp4\",\"id\":\"456\"}]"
    
    encodings = [Panda::Encoding.new({:abc => "http://a.b.com/file.mp4", :id => "456"})]    

    stub_http_request(:get, /myapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    stub_http_request(:get, /myapihost:85\/v2\/videos\/123\/encodings.json/).to_return(:body => encodings_json)

    video = Panda::Video.find("123")
    video.encodings.first.attributes.should == encodings.first.attributes
    
    Panda::Encoding.should_not_receive(:find_all_by_video_id)
    video.encodings
  end
  
  it "should allow to specify a connection" do
    video_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /myotherapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    connection = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myotherapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })

    cloud = Panda::Cloud.new
    cloud.connection = connection
    Panda::Video[cloud].find("123")
  end
  
  it "should allow to specify a connection" do
    video_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /myotherapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    connection = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myotherapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })

    cloud = Panda::Cloud.new
    cloud.connection = connection

    Panda::Video[cloud].find("123")
  end
  
  it "should delete a video" do
    video_json = "{\"deleted\":\"ok\"}"
    stub_http_request(:delete, /http:\/\/myapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)

    video = Panda::Video.new(:source_url => "http://a.b.com/file.mp4", :id => "123")
    
    video.new?.should == false
    video.delete.should == true
  end
  
  it "should delete a video" do
    video_json = "{\"deleted\":\"ok\"}"
    stub_http_request(:delete, /http:\/\/myapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)

    Panda::Video.delete("123")
  end
  
  it "should have an error object if something goes wrong" do
    response = "{\"message\":\"no-abc\",\"error\":\"error-abc\"}"
    
    stub_http_request(:get, /http:\/\/myapihost:85\/v2\/videos\/abc.json/).to_return(:body => response)
    
    lambda {
        Panda::Video.find "abc"
    }.should raise_error("error-abc: no-abc")
  end
  
  it "should have an error object if something goes wrong" do
    response = "{\"message\":\"no-abc\",\"error\":\"error-abc\"}"
    
    stub_http_request(:put, /http:\/\/myapihost:85\/v2\/profiles\/abc.json/).to_return(:body => response)
    
    obj = Panda::Profile.new (:id => "abc")
    original_attrs = obj.attributes
    obj.save
    
    obj.errors.size.should == 1
    obj.errors.first.message.should == "no-abc"
    obj.errors.first.error_class.should == "error-abc"
    obj.attributes.should == original_attrs
    
  end
  
  it "should connect to eu" do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}" 
    stub_http_request(:get, /http:\/\/api.eu.pandastream.com:80\/v2\/clouds\/my_cloud_id.json/).to_return(:body => cloud_json)

    Panda.configure do |c|
      c.access_key = "my_access_key"
      c.secret_key = "my_secret_key"
      c.cloud_id = 'my_cloud_id'
      c.region = "eu"
    end
    
    stub_http_request(:get, /http:\/\/api.eu.pandastream.com:80/).to_return(:body => "{\"id\":\"123\"}")
    Panda::Video.find "123"
  end
  
  it "test" do
    video_json = "{\"source_url\":\"http://a.b.com/file4.mp4\",\"id\":\"123\"}"
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"cloud1\"}"
    cloud2_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"cloud2\"}"

    stub_http_request(:get, /http:\/\/myotherapihost1:85\/v2\/clouds\/cloud1.json/).to_return(:body => cloud_json)    
    stub_http_request(:get, /http:\/\/myotherapihost2:85\/v2\/clouds\/cloud2.json/).to_return(:body => cloud2_json)

    stub_http_request(:get, /myotherapihost1:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    stub_http_request(:get, /myotherapihost2:85\/v2\/videos\/123.json/).to_return(:body => video_json)          
    
      connection = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myotherapihost1", "api_port" => 85, "cloud_id" => 'cloud1' })
      
      cloud = Panda::Cloud.new(:id => "cloud1")
      cloud.connection = connection
      
      connection2 = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myotherapihost2", "api_port" => 85, "cloud_id" => 'cloud2' })
      cloud2 = Panda::Cloud.new(:id => "cloud2")
      cloud2.connection = connection2
      
      video =  Panda::Video[cloud].find("123")
      video2 =  Panda::Video[cloud2].find("123")
      
      video.cloud.id.should == "cloud1"
      video2.cloud.id.should == "cloud2"

      Panda::Video.cloud.id.should == "my_cloud_id"
  end
  
  
  it "should use a finder proxy" do
    video_json = "{\"source_url\":\"http://a.b.com/file4.mp4\",\"id\":\"123\"}"
    
    stub_http_request(:get, /myotherapihost1:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    connection = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myotherapihost1", "api_port" => 85, "cloud_id" => 'cloud1' })
    
    cloud = Panda::Cloud.new
    cloud.connection = connection
    video =  Panda::Video[cloud].find("123")
  end
  
  it "should create a video" do
    video_json = "{\"source_url\":\"http://a.b.com/file4.mp4\",\"id\":\"123\"}"
    
    stub_http_request(:post, /myapihost:85\/v2\/videos.json/).
      with(:source_url => "panda.mp4").
        to_return(:body => video_json)
    
    video = Panda::Video.create(:source_url => "http://panda.mp4")
    video.id.should == "123"
  end
  
  
end