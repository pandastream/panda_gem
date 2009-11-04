module Panda
  class << self
    def connect!(access_key, secret_key, api_host='api.pandastream.com', api_port=80)
      @api_version = 2
      @access_key = access_key
      @secret_key = secret_key
      @api_host = api_host
      @api_port = api_port

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

    private

    def api_url
      "http://#{@api_host}:#{@api_port}/v#{@api_version}"
    end

    def append_authentication_params!(verb, request_uri, params)
      params['access_key'] = @access_key
      params['timestamp'] = Time.now.iso8601
      params['signature'] = ApiAuthentication.authenticate(verb, request_uri, @api_host, @secret_key, params)
      return params
    end

  end
end
