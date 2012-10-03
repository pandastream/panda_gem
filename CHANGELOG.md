## 1.6.0 (October 3, 2012)
    - Removed RestClient adapter
    - Removed Typhoeus gem dependency

      You can use any Faraday adapter by setting the default_adapter
      Panda.default_adapter = :excon

## 1.5.0 (October 17, 2011)

Features:

    - Faraday and Typhoeus by default
    - MultiJson
    - Added `urls`
    - Removed `screenshots` on video replaced by preview_url
    - Nicer inspect on resources
    - Added `metadata` on video and `cancel` and `retry` on encoding
    - Added direct access to a specific encoding using video.encodings['h264'] (if profile_name is h264)

## 1.4.4 (August 25, 2011)

Features:
    - Updated the faraday interface to use Typhoeus and recent Faraday

## 1.4.3 (August 18, 2011)

Features:
    Validates credentials on configure
    
## 1.4.2 (February 16, 2011)

Features:

    - Raises the api message on `save!`
    - Added `update_attributes!` method

Bugfixes:

    - `reload` method was raising after `create`

## 1.4.1 (February 4, 2011)

Features:

    - Fallback to RestClient (dependency pbs with heroku and faraday)

## 1.4.0 (February 4, 2011)

Features:

  - Replaced Restclient/json by Faraday/Yajl
  - Added Cloud.create, Cloud.all
  - Https support for heroku account
  - Simpler heroku configure method
  - Simpler configure method
  - Url and screenshots method for video
  - `create` method accepts a block
  - Removed support for JSON format
  
Bugfixes:
  - timestamp is UTC
  - `to_json` method
  - `create!` on associations was wrong

## 1.3.0 (January 10, 2011)

Features:

  - Added support for https

## 1.2.2 (December 08, 2010)

Bugfixes:

  - No more warnings about already initialized constants for JSON

## 1.2.0 (November 25, 2010)

Features:

  - Added support for the notification api.
  - Added support for path and url
  
## 1.1.0 (October 19, 2010)

Bugfixes:

  - Do not cache screenshot array anymore

## 1.0.0 (August 05, 2010)

- Simpler and smarter gem


    
    
    
    August 05, 2010