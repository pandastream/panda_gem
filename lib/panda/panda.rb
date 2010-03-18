require 'restclient'

class Panda
  def self.connect!(auth_params)
    @@connection = Connection.new(auth_params)
  end
  
  def self.get(request_uri, params={})
    @@connection.get(request_uri, params)
  end

  def self.post(request_uri, params)
    @@connection.post(request_uri, params)
  end

  def self.put(request_uri, params)
    @@connection.put(request_uri, params)
  end

  def self.delete(request_uri, params={})
    @@connection.delete(request_uri, params)
  end
  
  def self.authentication_params(*params)
    raise "Method deprecated. Please use signed_params instead."
  end
  
  def self.signed_params(verb, request_uri, params = {}, timestamp_str = nil)
    @@connection.signed_params(verb, request_uri, params, timestamp_str)
  end
  
  class Connection
    attr_reader :api_host, :api_port, :access_key, :secret_key, :api_version
  
    DEFAULT_API_PORT=80
    DEFAULT_API_HOST="api.pandastream.com"
  
    def initialize(auth_params)
      @api_version = 2
    
      if auth_params.class == String
        init_from_url(auth_params)
      else
        init_from_hash(auth_params)
      end
    
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


      def init_from_url(url)
        params = url.scan(/^([^:@]+):([^:@]+)@([^:@]+)(:[\d]+)?\/([^:@]+)$/).flatten

        @access_key = params[0]
        @secret_key = params[1]
        @cloud_id   = params[4]
        @api_host   = params[2]

        if params[3]
          @api_port = params[3][1..-1]
        else
          @api_port = DEFAULT_API_PORT
        end
        @prefix     = "v#{@api_version}"

      end

      def init_from_hash(hash_params)
        params      = { :api_host => DEFAULT_API_HOST, :api_port => DEFAULT_API_PORT }.merge(hash_params)

        @cloud_id   = params["cloud_id"]    || params[:cloud_id]
        @access_key = params["access_key"]  || params[:access_key]
        @secret_key = params["secret_key"]  || params[:secret_key]
        @api_host   = params["api_host"]    || params[:api_host]
        @api_port   = params["api_port"]    || params[:api_port]
        @prefix     = params["prefix_url"]  || "v#{@api_version}"
      end
  end
end