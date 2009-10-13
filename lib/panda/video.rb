require 'rubygems'
require 'restclient'
require 'api_authentication'

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
      RestClient::Resource.new(concat_urls(api_url, request_uri)).put(params)
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
    
    def authenticate(verb, request_uri, params)
      params['access_key'] = @access_key
      params['timestamp'] = Time.now.iso8601
      params['signature'] = ApiAuthentication.authenticate(verb, request_uri, @api_host, @secret_key, params)
      return params
    end

    def add_params_to_request_uri(request_uri, params)
      request_uri + '?' + hash_to_query(params)
    end
    # Insist on specific method of URL encoding, RFC3986. 
    def url_encode(string)
      # It's kinda like CGI.escape, except CGI.escape is encoding a tilde when
      # it ought not to be, so we turn it back. Also space NEEDS to be %20 not +.
      return CGI.escape(string).gsub("%7E", "~").gsub("+", "%20")
    end

    # Turns a hash into a query string, returns the query string.
    # url-encodes everything to Amazon's specifications. 
    def hash_to_query(hash)
      hash.collect do |key, value|

        url_encode(key) + "=" + url_encode(value)

      end.join("&")
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