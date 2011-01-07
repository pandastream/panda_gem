module Panda
  class Connection
    attr_accessor :api_host, :api_port, :access_key, :secret_key, :api_version, :cloud_id, :format

    API_PORT=80
    US_API_HOST="api.pandastream.com"
    EU_API_HOST="api.eu.pandastream.com"

    def initialize(auth_params={}, options={})
      @raise_error = false
      @api_version = 2
      @format = "hash"

      if auth_params.class == String
        self.format = options[:format] || options["format"]
        init_from_uri(auth_params)
      else
        self.format = auth_params[:format] || auth_params["format"]
        init_from_hash(auth_params)
      end
    end

    # Set the correct api_host for US/EU
    def region=(region)
      if(region.to_s == "us")
        self.api_host = US_API_HOST
      elsif(region.to_s == "eu")
        self.api_host = EU_API_HOST
      else
        raise "Region Unknown"
      end
    end

    # Setup connection for Heroku
    def heroku=(url)
      init_from_uri(url)
    end

    # Raise exception on non JSON parsable response if set
    def raise_error=(bool)
      @raise_error = bool
    end

    # Setup respond type JSON / Hash
    def format=(ret_format)
      if ret_format
        raise "Format unknown" if !["json", "hash"].include?(ret_format.to_s)
        @format = ret_format.to_s
      end
    end

    # Authenticated requests

    def get(request_uri, params={})
      @connection = RestClient::Resource.new(api_url)
      rescue_restclient_exception do
        query = signed_query("GET", request_uri, params)
        body_of @connection[request_uri + '?' + query].get
      end
    end

    def post(request_uri, params={})
      @connection = RestClient::Resource.new(api_url)
      rescue_restclient_exception do
        body_of @connection[request_uri].post(signed_params("POST", request_uri, params))
      end
    end

    def put(request_uri, params={})
      @connection = RestClient::Resource.new(api_url)
      rescue_restclient_exception do
        body_of @connection[request_uri].put(signed_params("PUT", request_uri, params))
      end
    end

    def delete(request_uri, params={})
      @connection = RestClient::Resource.new(api_url)
      rescue_restclient_exception do
        query = signed_query("DELETE", request_uri, params)
        body_of @connection[request_uri + '?' + query].delete
      end
    end

    # Signing methods
    def signed_query(*args)
      ApiAuthentication.hash_to_query(signed_params(*args))
    end

    def signed_params(verb, request_uri, params = {}, timestamp_str = nil)
      auth_params = stringify_keys(params)
      auth_params['cloud_id']   = cloud_id
      auth_params['access_key'] = access_key
      auth_params['timestamp']  = timestamp_str || Time.now.iso8601(6)

      params_to_sign = auth_params.reject{|k,v| ['file'].include?(k.to_s)}
      auth_params['signature']  = ApiAuthentication.generate_signature(verb, request_uri, api_host, secret_key, params_to_sign)
      auth_params
    end

    def api_url
      "#{api_protocol}://#{api_host}:#{api_port}/#{@prefix}"
    end

    def api_protocol
      api_port == 443 ? 'https' : 'http'
    end
    
    # Shortcut to setup your bucket
    def setup_bucket(params={})
      granting_params = { 
        :s3_videos_bucket => params[:bucket],
        :user_aws_key => params[:access_key],
        :user_aws_secret => params[:secret_key]
      }

      put("/clouds/#{@cloud_id}.json", granting_params)
    end

    def to_hash
      hash = {}
      [:api_host, :api_port, :access_key, :secret_key, :api_version, :cloud_id].each do |a|
        hash[a] = send(a)
      end
      hash
    end

    private
      def stringify_keys(params)
        params.inject({}) do |options, (key, value)|
          options[key.to_s] = value
          options
        end
      end

      def rescue_restclient_exception(&block)
        begin
          yield
        rescue RestClient::Exception => e
          format_to(e.http_body)
        end
      end

      # API change on rest-client 1.4
      def body_of(response)
        json_response = response.respond_to?(:body) ? response.body : response
        format_to(json_response)
      end

      def format_to(response)
        begin
          if self.format == "json"
            response
          elsif defined?(ActiveSupport::JSON)
            ActiveSupport::JSON.decode(response)
          else
            JSON.parse(response)
          end
        rescue JSON::ParserError => e
          # if not used with PandaResources
          # don't raise Service Not Available because
          # maybe the host, the url, or anything is wrongly setup
          if @raise_error
            raise ServiceNotAvailable.new
          else
            raise e
          end
        end
      end

      def init_from_uri(uri)
        heroku_uri = URI.parse(uri)
        
        @access_key = heroku_uri.user
        @secret_key = heroku_uri.password
        @cloud_id   = heroku_uri.path[1..-1]
        @api_host   = heroku_uri.host
        @api_port   = heroku_uri.port
        @prefix     = "v#{api_version}"
      end

      def init_from_hash(hash_params)
        params      = { :api_host => US_API_HOST, :api_port => API_PORT }.merge!(hash_params)

        @cloud_id   = params["cloud_id"]    || params[:cloud_id]
        @access_key = params["access_key"]  || params[:access_key]
        @secret_key = params["secret_key"]  || params[:secret_key]
        @api_host   = params["api_host"]    || params[:api_host]
        @api_port   = params["api_port"]    || params[:api_port]
        @prefix     = params["prefix_url"]  || "v#{api_version}"
      end
  end
end

