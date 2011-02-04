module Panda
  
  API_PORT=443
  US_API_HOST="api.pandastream.com"
  EU_API_HOST="api.eu.pandastream.com"
  
  class Connection
    attr_accessor :api_host, :api_port, :access_key, :secret_key, :api_version, :cloud_id

    def initialize(auth_params={})
      @api_version = 2
      init_from_hash(auth_params)
    end

    def adapter
      @adapter ||= Panda.adapter.new(api_url)
    end
    
    # Authenticated requests
    def get(request_uri, params={})
      sp = signed_params("GET", request_uri, params)
      adapter.get(request_uri, sp)
    end

    def post(request_uri, params={})
      sp = signed_params("POST", request_uri, params)
      adapter.post(request_uri, sp)
    end

    def put(request_uri, params={})
      sp = signed_params("PUT", request_uri, params)
      adapter.put(request_uri, sp)
    end

    def delete(request_uri, params={})
      sp = signed_params("DELETE", request_uri, params)
      adapter.delete(request_uri, sp)
    end

    # Signing methods
    def signed_query(*args)
      ApiAuthentication.hash_to_query(signed_params(*args))
    end

    def signed_params(verb, request_uri, params = {}, timestamp_str = nil)
      auth_params = stringify_keys(params)
      auth_params['cloud_id']   = cloud_id unless request_uri =~ /^\/clouds/
      auth_params['access_key'] = access_key
      auth_params['timestamp']  = timestamp_str || Time.now.utc.iso8601(6)

      params_to_sign = auth_params.reject{|k,v| ['file'].include?(k.to_s)}
      auth_params['signature']  = ApiAuthentication.generate_signature(verb, request_uri, api_host, secret_key, params_to_sign)
      auth_params
    end

    def api_url
      "#{api_scheme}://#{api_host}:#{api_port}/#{@prefix}"
    end

    def api_scheme
      api_port == 443 ? 'https' : 'http'
    end
    
    # Shortcut to setup your bucket
    def setup_bucket(params={})
      granting_params = { 
        :s3_videos_bucket => params[:bucket],
        :aws_access_key => params[:access_key],
        :aws_secret_key => params[:secret_key]
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

    def init_from_hash(hash_params)
      params = { :api_host => US_API_HOST, :api_port => API_PORT }.merge!(hash_params)

        @cloud_id   = params["cloud_id"]    || params[:cloud_id]
        @access_key = params["access_key"]  || params[:access_key]
        @secret_key = params["secret_key"]  || params[:secret_key]
        @api_host   = params["api_host"]    || params[:api_host]
        @api_port   = params["api_port"]    || params[:api_port]
        @prefix     = params["prefix_url"]  || "v#{api_version}"
    end
  end
end

