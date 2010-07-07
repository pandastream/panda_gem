require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Video do
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
    stub_http_request(:get, /myapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)

    encodings = [Panda::Encoding.new({:abc => "efg", :id => "456"})]    
    Panda::Encoding.should_receive(:find_all_by_video_id).with("123").and_return(encodings)
    
    video = Panda::Video.find("123")
    video.encodings.should == encodings
    
    Panda::Encoding.should_not_receive(:find_all_by_video_id)
    video.encodings
  end
  
  it "should allow to specify a connection" do
    video_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}"
    stub_http_request(:get, /myotherapihost:85\/v2\/videos\/123.json/).to_return(:body => video_json)
    connection = Panda::Connection.new({"access_key" => "my_access_key", "secret_key" => "my_secret_key", "api_host" => "myotherapihost", "api_port" => 85, "cloud_id" => 'my_cloud_id' })
    Panda::Video[connection].find("123")
  end
  
  it "should create a video" do
    video_json = "{\"source_url\":\"http://a.b.com/file.mp4\",\"id\":\"123\"}"
    stub_http_request(:post, /http:\/\/myapihost:85\/v2\/videos.json/).
      with(:source_url =>"http://a.b.com/file.mp4").
        to_return(:body => video_json)

    video = Panda::Video.new(:source_url => "http://a.b.com/file.mp4")
    
    video.new?.should == true
    video.save.should == true
    video.id.should == "123" 
    video.new?.should == false
  end
  
  it "should not call update a video" do
    video_json = "{\"source_url\":\"http://a.b.com/file4.mp4\",\"id\":\"123\"}"
    stub_http_request(:put, /http:\/\/myapihost:85\/v2\/videos\/123.json/).
      with(:source_url =>"http://a.b.com/file.mp4").
        to_return(:body => video_json)

    video = Panda::Video.new(:source_url => "http://a.b.com/file.mp4", :id => "123")
    
    video.new?.should == false
    video.save.should == false
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
    Panda.configure do |c|
      c.access_key = "my_access_key"
      c.secret_key = "my_secret_key"
      c.cloud_id = 'my_cloud_id'
      c.region = "eu"
    end
    
    stub_http_request(:get, /http:\/\/api.eu.pandastream.com:80/).to_return(:body => "{\"id\":\"123\"}")
    Panda::Video.find "123"
  end
  
  
end