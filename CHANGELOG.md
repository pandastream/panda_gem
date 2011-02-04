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