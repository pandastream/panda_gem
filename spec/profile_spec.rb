require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Panda::Profile do
  before(:each) do
    cloud_json = "{\"s3_videos_bucket\":\"my_bucket\",\"id\":\"my_cloud_id\"}" 
    stub_http_request(:get, /api.example.com:85\/v2\/clouds\/my_cloud_id.json/).
      to_return(:body => cloud_json)

    Panda.configure do |c|
      c.access_key = "my_access_key"
      c.secret_key = "my_secret_key"
      c.api_host = "api.example.com"
      c.cloud_id = 'my_cloud_id'
      c.api_port = 85
    end
    
  end

  it "should create a video" do
    profile_json = "{\"title\":\"my_profile\",\"id\":\"123\"}"
    stub_http_request(:post, /api.example.com:85\/v2\/profiles.json/).
      with(:body => /title=my_profile/).
        to_return(:body => profile_json)

    profile = Panda::Profile.new(:title => "my_profile")
    
    profile.new?.should == true
    profile.save.should == true
    profile.id.should == "123" 
    profile.new?.should == false
  end


  it "should update a video and sending the changed attributes" do
    profile_json = "{\"title\":\"my_profile\",\"id\":\"123\"}"
    stub_http_request(:put, /api.example.com:85\/v2\/profiles\/999.json/).
      with{|r| !(r.body =~ /title=my_new_profile_title/) && r.body =~ /width=80/}.
        to_return(:body => profile_json)

    profile = Panda::Profile.new(:id => "999", :title => "my_profile_title")
    
    profile.width=80    
    profile.new?.should == false
    profile.save.should == true
  end


  it "should not call update a video" do
    profile_json = "{\"title\":\"my_profile\",\"id\":\"123\"}"
    stub_http_request(:put, /api.example.com:85\/v2\/profiles\/123.json/).
      with(:body => /title=my_profile/).
        to_return(:body => profile_json)

    profile = Panda::Profile.new(:id => "123")
    profile.title = "my_profile"
    
    profile.new?.should == false
    profile.save.should == true
  end


  it "should have a many relation on encodings" do
    encoding_json = "[{\"abc\":\"efg\",\"id\":456}]"
    profile_json = "{\"title\":\"my_profile\",\"id\":\"901\"}"
    stub_http_request(:get, /api.example.com:85\/v2\/profiles\/901\/encodings.json/).
      to_return(:body => encoding_json)
    
    profile = Panda::Profile.new(:title => "my_source_url", :id => "901")
    profile.encodings.first.id.should ==  456
  end
  
end