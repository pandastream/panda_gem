require 'restclient'

class Panda
  attr_reader :api_host, :api_port, :access_key, :secret_key, :api_version
  
  def initialize(auth_params={})
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
    rescue_restclient_exception do
      query = signed_query("GET", request_uri, params)
      body_of @connection[request_uri + '?' + query].get
    end
  end

  def post(request_uri, params)
    rescue_restclient_exception do
      body_of @connection[request_uri].post(signed_params("POST", request_uri, params))
    end
  end

  def put(request_uri, params)
    rescue_restclient_exception do
      body_of @connection[request_uri].put(signed_params("PUT", request_uri, params))
    end
  end

  def delete(request_uri, params={})
    rescue_restclient_exception do
      query = signed_query("DELETE", request_uri, params)
      body_of @connection[request_uri + '?' + query].delete
    end
  end
  
  def authentication_params(verb, request_uri, params)
    auth_params = {}
    auth_params['cloud_id'] = @cloud_id
    auth_params['access_key'] = @access_key
    auth_params['timestamp'] = Time.now.iso8601(6)
    auth_params['signature'] = ApiAuthentication.authenticate(verb, request_uri, @api_host, @secret_key, params.merge(auth_params))
    return auth_params
  end
  
  def signed_query(*args)
    ApiAuthentication.hash_to_query(signed_params(*args))
  end
  
  def signed_params(verb, request_uri, params = {}, timestamp_str = nil)
    auth_params = params
    auth_params['cloud_id']   = @cloud_id
    auth_params['access_key'] = @access_key
    auth_params['timestamp']  = timestamp_str || Time.now.iso8601(6)
    
    params_to_sign = auth_params.reject{|k,v| ['file'].include?(k)}
    auth_params['signature']  = ApiAuthentication.generate_signature(verb, request_uri, @api_host, @secret_key, params_to_sign)
    auth_params
  end
  
  def api_url
    "http://#{@api_host}:#{@api_port}/#{@prefix}"
  end
  
  def setup_bucket(params={})
    granting_params = { :s3_videos_bucket => params[:bucket], :user_aws_key => params[:access_key], :user_aws_secret => params[:secret_key] }
    put("/clouds/#{@cloud_id}.json", granting_params)
  end
  
  private
  
  def rescue_restclient_exception(&block)
    begin 
      yield 
    rescue RestClient::Exception => e
      e.http_body
    end
  end
  
  # API change on rest-client 1.4
  def body_of(response)
    response.respond_to?(:body) ? response.body : response
  end
end
