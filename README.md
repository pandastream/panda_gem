# ALPHA VERSION -- DO NOT USE!!

# Panda

Panda gem provides an interface to access the [Panda](http://pandastream.com) API from Ruby.

## Installation

    sudo gem install panda -s http://gemcutter.org

## How to use it

    require 'rubygems'
    require 'panda'

### Creating an instance of the client

    Panda.configure do |c|
      c.access_key = "panda_access_key"
      c.secret_key = "panda_secret_key"
      c.cloud_id = "panda_cloud_id"
    end

### Creating an instance of the client for EU

    Panda.configure do |c|
      c.access_key = "panda_access_key"
      c.secret_key = "panda_secret_key"
      c.cloud_id = "panda_cloud_id"
      c.region = "eu"
    end

###  Videos

#### Find a video

    video = Panda::Video.find "1234"
    video.attributes
    => {
      "id"=>"1234",
      "original_filename"=>"panda.mp4",
      "source_url"=>"http://www.example.com/original_video.mp4",
      "extname"=>".mp4",
      "duration"=>14010,
      "audio_codec"=>"aac",
      "video_codec"=>"h264",
      "file_size" => "44000",
      "width"=>300,
      "height"=>240,
      "fps"=>29,
      "status"=>"success",
      "created_at"=>"2010/01/13 16:45:29 +0000",
      "updated_at"=>"2010/01/13 16:45:35 +0000"
    }

    video.id
    => "1234"
    
    video.created_at
    =>"2010/01/13 16:45:29 +0000"
    
    video = Panda::Video.find "fake_id"
    => raise: RecordNotFound: Couldn't find Video with ID=fake_id

##### Find encodings of a video
    
    video = Panda::Video.find "1234"
    video.encodings
    => [...]

##### Find all videos

    videos = Panda::Video.all
    => [...]
    
    videos.first.id
    => "3456"

    videos = Panda::Video.all(:page => 2, :per_page => 20)
    videos.size
    => 20

##### Find all success videos

    videos = Panda::Video.all(:status => "success")
    => [...]

#### Create a new video

  from a source
    
    video = Panda::Video.create(:source_url => "http://mywebsite.com/myvideo.mp4")
    
    or
    
    video = Panda::Video.new(:source_url => "http://mywebsite.com/myvideo.mp4")
    video.create
    => true
    
  from a local file
    
    video = Panda::Video.create(:file => File.new("/home/me/panda.mp4"))
    
  or
    
    video = Panda::Video.new(:file => File.new("/home/me/panda.mp4"))
    video.create
    => true

#### Delete a video

    Panda::Video.delete("1234")
    
  or 
  
    video = Panda::Video.find "1234"
    video.delete
    => true
    
###  Encodings

##### Find an encoding

    encoding = Panda::Encoding.find "4567"
    encoding.attributes
    => {
      "id"=>"4567",
      "video_id"=>"1234",
      "extname"=>".mp4",
      "encoding_progress"=>60,
      "encoding_time"=>3,
      "file_size" => "25000",
      "width"=>300,
      "height"=>240,
      "profile_id"=>"6789",
      "status"=>"success",
      "started_encoding_at"=>"2010/01/13 16:47:35 +0000",
      "created_at"=>"2010/01/13 16:45:30 +0000",
      "updated_at"=>"2010/01/13 16:47:40 +0000"
    }
      
    encoding.encoding_progress
    => 60
    
    encoding.video.original_filename
    => "panda.mp4"
    
##### Find all encodings of a video

    encodings = Panda::Encoding.all(:page => 4)
    => [...]
    
    encodings = Panda::Encoding.find_all_by_video_id(video_id)
    => [...]
    
    profile = Panda::Encoding.find_by :video_id => "video_id", :profile_name => "h264"
    profile.encoding_time
    => 3
    
    profile = encodings.first.profile
    profile.title
    => "H264 profile"

##### Find all success encodings

    encodings = Panda::Encoding.all(:video_id => "1234", :status => "success")
    => [...]

##### Retrieve the encoding 

    encoding = Panda::Encoding.find "4567"
    encoding.url
    => "http://s3.amazonaws.com/my_panda_bucket/4567.mp4"

##### Create a new encoding

    encoding = Panda::Encoding.create(:video_id => 1234, :profile_id => 6789)
    encoding.status
    => "processing"

  or 
    
    video = Panda::Video.find "123"
    encoding = video.encoding.find "4567"
    video.encoding.create(:profile => "profile_id")
    
##### Delete an encoding

    Panda::Encoding.delete("4567")
    
  or 
    
    encoding = Panda::Encoding.find "4567"
    encoding.delete
    => true
    
###  Profiles

##### Create a profile

    profile = Panda::Profile.find "6789"
    profiles = Panda::Profile.all
    
    profile = Panda::Profile.create(:preset_name => "h264")
    profile = Panda::Profile.create(:command => "ffmpeg -i $input_file$ -y $output_file$", ....)

##### Update a profile

    profile = Panda::Profile.find "6789"
    profile.width = 320
    profile.height = 280
    profile.save
    => true
    
    profile.id = "fake_profile_id"
    profile.save
    => false
    
    profile.errors.first.to_s
    => RecordNotFound: Couldn't find Profile with ID=fake_profile_id

##### Delete a profile

    Panda::Profile.delete("4567")

  or

    profile = Panda::Profile.find "6789"
    profile.delete
    => true

##### All encoding of a profile

    profile = Panda::Profile.find "6789"
    profile.encodings
    => [...]
    
    profile = Panda::Profile.find "6789"
    profile.encoding.all(:status => "success")

###  Using multiple clouds

    cloud_one = Panda::Cloud.find "cloud_id_1"
    cloud_two = Panda::Cloud.find "cloud_id_2"
  
    cloud_one.profiles
    cloud_two.profiles.find "profile_id"

    cloud_two.videos
    cloud_two.videos.all(:status => "success")
    cloud_two.videos.all(:page => 2)

    cloud_one.videos.find "video_id_1"
    cloud_two.videos.find "video_id_2"
    
    cloud_two.profiles
    cloud_two.profiles.create(:preset_name => "h264")
    cloud_one.videos.create(:command => "ffmpeg -i $input_file$ -y $output_file$", ....)

## Old Panda way, still works

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
    
### Deleting an encoding

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
