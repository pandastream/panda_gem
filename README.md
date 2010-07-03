# ALFA VERSION -- DO NOT USE!!

# Panda

Panda gem provides an interface to access the [Panda](http://pandastream.com) API from Ruby.

## Installation

    sudo gem install panda -s http://gemcutter.org

## How to use it

    require 'rubygems'
    require 'panda'

### Creating an instance of the client

    Panda.configure do |c|
      c.access_key = "access_key"
      c.secret_key = "secret_key"
      c.cloud_id = "cloud_id"
    end

###  Videos

    video = Panda::Video.find "video_id"
    video.id
    video.created_at

    encodings = video.encodings
    
    videos = Panda::Video.all
    videos.first.id
    
    video = Panda::Video.new(:source_url => "http://mywebsite.com/myvideo.mp4")
    video.save

    video.delete
    
###  Encodings

    encoding = Panda::Encoding.find ""
    encoding.id
  
    encodings = Panda::Encoding.all
  
    encodings.progress
    profile = encodings.first.profile
    encoding.video.id

    encoding = Panda::Encoding.new(:profile_id => profile.id)
    encoding.save

    encoding.delete
###  Profiles

    profile = Panda::Profile.find "profile_id"
    profile.title

    profiles = Panda::Profile.all
    
    profile = Panda::Profile.new(:preset_name => "h264")
    profile.save
    
    profile.width = 280
    profile.height = 320
    profile.save
    
    profile.delete

###  Using multiple clouds

    cloud_one = Panda::Cloud.find "cloud_id_1"
    cloud_two = Panda::Cloud.find "cloud_id_2"
  
    cloud_two.profiles.find "profile_id"
  
    cloud_one.video.find "video_id_1"
    cloud_two.video.find "video_id_2"
  
###  Using a model with a specific connection
    @connection = Panda::Connection.new({ :access_key => "" .... })
    Panda::Video[@connection].find "video_id"
  

# Old Panda way, still works

### Creating an instance of the client
    
    Panda.connect!({
      :cloud_id => 'cloud_id', 
      :access_key => 'access_key', 
      :secret_key => 'secret_key', 
      :api_host => 'api.pandastream.com' # This may change depending on the region
    })

### Posting a video

    Panda.post('/videos.json', {:file => File.new("panda.mp4")}) # Note that you will need a movie file to test this. You can grab http://panda-test-harness-videos.s3.amazonaws.com/panda.mp4

    Panda.post('/videos.json', {:source_url => 'http://www.example.com/original_video.mp4'})
    =>{"duration"=>nil,
     "created_at"=>"2010/01/15 14:48:42 +0000",
     "original_filename"=>"panda.mp4",
     "updated_at"=>"2010/01/15 14:48:42 +0000",
     "source_url"=>"http://www.example.com/original_video.mp4",
     "id"=>"12fce296-01e5-11df-ae37-12313902cc92",
     "extname"=>".mp4",
     "audio_codec"=>nil,
     "height"=>nil,
     "upload_redirect_url"=>nil,
     "fps"=>nil,
     "video_codec"=>nil,
     "status"=>"processing",
     "width"=>nil}
    
### Getting all videos

    Panda.get('/videos.json')
    => [{"duration"=>14010,
      "created_at"=>"2010/01/13 16:45:29 +0000",
      "original_filename"=>"panda.mp4",
      "updated_at"=>"2010/01/13 16:45:35 +0000",
      "source_url"=>"http://www.example.com/original_video.mp4",
      "id"=>"0ee6b656-0063-11df-a433-1231390041c1",
      "extname"=>".mp4",
      "audio_codec"=>"aac",
      "height"=>240,
      "upload_redirect_url"=>nil,
      "fps"=>29,
      "video_codec"=>"h264",
      "status"=>"success",
      "width"=>300}]
    
### Getting video encodings 
    
    Panda.get('/videos/0ee6b656-0063-11df-a433-1231390041c1/encodings.json')
    => [{"encoder_id"=>nil,
      "created_at"=>"2010/01/13 16:45:30 +0000",
      "video_id"=>"0ee6b656-0063-11df-a433-1231390041c1",
      "video_url"=> 
          "http://s3.amazonaws.com/panda-videos/0f815986-0063-11df-a433-1231390041c1.flv",
      "started_encoding_at"=>"2010/01/13 16:47:35 +0000",
      "updated_at"=>"2010/01/13 16:47:40 +0000",
      "extname"=>".flv",
      "encoding_progress"=>87,
      "encoding_time"=>3,
      "id"=>"0f815986-0063-11df-a433-1231390041c1",
      "height"=>240,
      "status"=>"success",
      "profile_id"=>"00182830-0063-11df-8c8a-1231390041c1",
      "width"=>300}]
    
### Deleting a video encoding

    Panda.delete('/encodings/0f815986-0063-11df-a433-1231390041c1.json')

### Deleting a video
    
    Panda.delete('/videos/0ee6b656-0063-11df-a433-1231390041c1.json')

## Generating signatures

All requests to your Panda cloud are signed using HMAC-SHA256, based on a timestamp and your Panda secret key. This is handled transparently. However, sometimes you will want to generate only this signature, in order to make a request by means other than this library. This is the case when using the [JavaScript panda_uploader](http://github.com/newbamboo/panda_uploader).

To do this, a method `signed_params()` is supported:

    Panda.signed_params('POST', '/videos.json')
    # => {'access_key' => '8df50af4-074f-11df-b278-1231350015b1',
    # 'cloud_id' => 'your-cloud-id',
    # 'signature' => 'LejCdm0O83+jk6/Q5SfGmk14WTO1pB6Sh6Z5eA2w5C0=',
    # 'timestamp' => '2010-02-26T15:01:46.221513'}

    Panda.signed_params('GET', '/videos.json', {'some_params' => 'some_value'})
    # => {'access_key' => '8df50af4-074f-11df-b278-1231350015b1',
    #  'cloud_id' => 'your-cloud-id',
    #  'signature' => 'uHnGZ+kI9mT3C4vW71Iop9z2N7UKCv38v2l2dvREUIQ=',
    #  'some_param' => 'some_value',
    #  'timestamp' => '2010-02-26T15:04:27.039620'}

## Hash or JSON
Since Panda 0.6, PandaGem returns a Hash by default. If you want PandaGem to return JSON do the following:

    Panda.connect!({
      :cloud_id => 'cloud_id',
      :access_key => 'access_key',
      :secret_key => 'secret_key',
      :format => 'json'
    })


Copyright
---------

Copyright (c) 2009-2010 New Bamboo. See LICENSE for details.
