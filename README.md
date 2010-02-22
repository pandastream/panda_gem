# Panda

Panda gem provides an interface to access the [Panda](http://pandastream.com) API from Ruby.

## Installation

    sudo gem install panda -s http://gemcutter.org

## How to use it

    require 'panda'

### Creating an instance of the client

    panda = Panda.new({
      :cloud_id => 'cloud_id', 
      :access_key => 'access_key', 
      :secret_key => 'secret_key', 
      :api_host => 'api.pandastream.com' # This may change depending on the region
    })

### Posting a video
    
    panda.post('/videos.json', {:source_url => 'http://www.example.com/original_video.mp4'})
    =>{"duration"=>nil,
     "created_at"=>"2010/01/15 14:48:42 +0000",
     "original_filename"=>"panda.mp4",
     "updated_at"=>"2010/01/15 14:48:42 +0000",
     "source_url"=>"http://www.example.com/original_video.mp4",
     "id"=>"12fce296-01e5-11df-ae37-12313902cc92",
     "extname"=>".mp4",
     "thumbnail_position"=>nil,
     "audio_codec"=>nil,
     "height"=>nil,
     "upload_redirect_url"=>nil,
     "fps"=>nil,
     "video_codec"=>nil,
     "status"=>"processing",
     "width"=>nil}
    
### Getting all videos

    panda.get('/videos.json')
    => [{"duration"=>14010,
      "created_at"=>"2010/01/13 16:45:29 +0000",
      "original_filename"=>"panda.mp4",
      "updated_at"=>"2010/01/13 16:45:35 +0000",
     "source_url"=>"http://www.example.com/original_video.mp4",
      "id"=>"0ee6b656-0063-11df-a433-1231390041c1",
      "extname"=>".mp4",
      "thumbnail_position"=>nil,
      "audio_codec"=>"aac",
      "height"=>240,
      "upload_redirect_url"=>nil,
      "fps"=>29,
      "video_codec"=>"h264",
      "status"=>"success",
      "width"=>300}]
    
### Getting video encodings 
    
    panda.get('/videos/0ee6b656-0063-11df-a433-1231390041c1/encodings.json')
    => [{"encoder_id"=>nil,
      "created_at"=>"2010/01/13 16:45:30 +0000",
      "video_id"=>"0ee6b656-0063-11df-a433-1231390041c1",
      "video_url"=>
       "http://s3.amazonaws.com/panda-videos/0f815986-0063-11df-a433-1231390041c1.flv",
      "started_encoding_at"=>"2010/01/13 16:47:35 +0000",
      "updated_at"=>"2010/01/13 16:47:40 +0000",
      "lock_version"=>7,
      "extname"=>".flv",
      "encoding_progress"=>87,
      "encoding_time"=>3,
      "id"=>"0f815986-0063-11df-a433-1231390041c1",
      "height"=>240,
      "status"=>"success",
      "profile_id"=>"00182830-0063-11df-8c8a-1231390041c1",
      "width"=>300}]
    
### Deleting a video encoding

    panda.delete('/encodings/0f815986-0063-11df-a433-1231390041c1.json')

### Deleting a video
    
    panda.delete('/videos/0ee6b656-0063-11df-a433-1231390041c1.json')

Copyright
---------

Copyright (c) 2009-2010 New Bamboo. See LICENSE for details.
