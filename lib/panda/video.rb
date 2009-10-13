require 'rubygems'
require 'cgi'
require 'time'
require 'hmac'
require 'hmac-sha2'
require 'base64'
require 'restclient'

module Panda
  class << self
    attr_writer :rest_client_options
    attr_reader :connection
    
    def connect!(access_key, secret_key, api_host='api.pandastream.com', api_port=80)
      @access_key = access_key
      @secret_key = secret_key
      @api_host = api_host
      @api_port = api_port
      @rest_client_options = {}
      
      # raise Exception.new("You must supply a :secret_key") unless @secret_key
      
      @connection = RestClient::Resource.new(api_url)
    end
    
    def api_url
      "http://#{@api_host}:#{@api_port}"
    end
    
    # NOTE: get params, MUST be given as the params hash, not as part of the url string
    def get(request_uri, params={})
      params = authenticate("GET", request_uri, params)
      puts add_params_to_request_uri(request_uri, params)
      RestClient::Resource.new(concat_urls(api_url, add_params_to_request_uri(request_uri, params))).get
    end

    def post(request_uri, params)
      params = authenticate("POST", request_uri, params)
      RestClient::Resource.new(concat_urls(api_url, request_uri)).post(params)
    end

    def put(request_uri, params)
      params = authenticate("PUT", request_uri, params)
      RestClient::Resource.new(concat_urls(api_url, request_uri)).post(params)
    end

    def delete(request_uri, params={})
      params = authenticate("DELETE", request_uri, params)
      puts add_params_to_request_uri(request_uri, params)
      RestClient::Resource.new(concat_urls(api_url, add_params_to_request_uri(request_uri, params))).delete
    end
    
    # From rest-client/lib/restclient/resource.rb
    
    def concat_urls(url, suburl)   # :nodoc:
			url = url.to_s
			suburl = suburl.to_s
			if url.slice(-1, 1) == '/' or suburl.slice(0, 1) == '/'
				url + suburl
			else
				"#{url}/#{suburl}"
			end
		end

    # Authentication

    def add_params_to_request_uri(request_uri, params)
      request_uri + '?' + canonical_querystring(params)
    end

    def authenticate(verb, request_uri, params={})
      # supply timestamp and access key if not already provided
      params["timestamp"] ||= Time.now.iso8601
      params["access_key"] ||= @access_key
      # Existing "Signature"? That's gotta go before we generate a new
      # signature and add it. 
      params.delete("signature")

      query_string = canonical_querystring(params)
      
      string_to_sign = verb + "\n" + 
          @api_host.downcase + "\n" +
          request_uri + "\n" +
          query_string
      puts string_to_sign
      hmac = HMAC::SHA256.new( @secret_key )
      hmac.update( string_to_sign )
      # chomp is important!  the base64 encoded version will have a newline at the end
      signature = Base64.encode64(hmac.digest).chomp 

      params["signature"] = signature

      #order doesn't matter for the actual request, we return the hash
      #and let client turn it into a url.
      puts params.inspect
      return params
		end
		
    # Insist on specific method of URL encoding, RFC3986. 
    def url_encode(string)
      # It's kinda like CGI.escape, except CGI.escape is encoding a tilde when
      # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
      return CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
    end

    # param keys should be strings, not symbols please. return a string joined
    # by & in canonical order. 
    def canonical_querystring(params)
      # I hope this built-in sort sorts by byte order, that's what's required. 
      values = params.keys.sort.collect {|key|  [url_encode(key), url_encode(params[key].to_s)].join("=") }

      return values.join("&")
    end

  end
  
  # class AccountKeyNotSet < PandaError; end
  # 
  # # 4xx Client Error
  # class ClientError < ConnectionError; end # :nodoc:
  # 
  # # 401 Unauthorized
  # class UnauthorizedAccess < ClientError; end # :nodoc
  # 
  # # 404 Not Found
  # class VideoNotFound < ClientError; end # :nodoc:
  # 
  # # 5xx Server Error
  # class ServerError < ConnectionError; end # :nodoc:
end