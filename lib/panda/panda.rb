require 'restclient'

module Panda
  class << self
    
    def connect!(auth_params={})
      params = {:api_host => 'api.pandastream.com', :api_port => 80 }.merge(auth_params)
      
      @api_version = 2
      @cloud_id = params["cloud_id"] || params[:cloud_id]
      @access_key = params["access_key"] || params[:access_key]
      @secret_key = params["secret_key"] || params[:secret_key]
      @api_host = params["api_host"] || params[:api_host]
      @api_port = params["api_port"] || params[:api_port]
      
      @prefix = params["prefix_url"] || "v#{@api_version}"
      
      @connection = RestClient::Resource.new(api_url)
    end
    
    def get(request_uri, params={})
      append_authentication_params!("GET", request_uri, params)
      @connection[ApiAuthentication.add_params_to_request_uri(request_uri, params)].get
    end

    def post(request_uri, params)
      append_authentication_params!("POST", request_uri, params)
      @connection[request_uri].post(params)
    end

    def put(request_uri, params)
      append_authentication_params!("PUT", request_uri, params)
      @connection[request_uri].put(params)
    end

    def delete(request_uri, params={})
      append_authentication_params!("DELETE", request_uri, params)
      @connection[ApiAuthentication.add_params_to_request_uri(request_uri, params)].delete
    end
    
    def authentication_params(verb, request_uri, params)
      auth_params = {}
      auth_params['cloud_id'] = @cloud_id
      auth_params['access_key'] = @access_key
      auth_params['timestamp'] = Time.now.iso8601
      auth_params['signature'] = ApiAuthentication.authenticate(verb, request_uri, @api_host, @secret_key, params.merge(auth_params))
      return auth_params
    end
    
    def api_url
      "http://#{@api_host}:#{@api_port}/#{@prefix}"
    end
    private
    
    def append_authentication_params!(verb, request_uri, params)
      auth_params = authentication_params(verb, request_uri, params)
      params.merge!(auth_params)
    end

  end
end
