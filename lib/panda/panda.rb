require 'restclient'
require 'json' unless defined?(ActiveSupport::JSON)

module Panda
  class << self
    attr_accessor :cloud, :clouds
    attr_writer :connection

    def configure(auth_params=nil, options={})
      @clouds = {}
      @connection = Panda::Connection.new
      
      if auth_params
        connect!(auth_params, options)
      else
        yield @connection
      end
      
      connection.raise_error=true
      connection.format = :hash
      @cloud = Cloud::new(:id => connection.cloud_id)
    end
    
    def connect!(auth_params, options={})
      self.connection = Connection.new(auth_params, options)
    end
    
    def get(request_uri, params={})
      connection.get(request_uri, params)
    end
    
    def post(request_uri, params={})
      connection.post(request_uri, params)
    end
    
    def put(request_uri, params={})
      connection.put(request_uri, params)
    end
    
    def delete(request_uri, params={})
      connection.delete(request_uri, params)
    end
    
    def setup_bucket(params={})
      connection.setup_bucket(params)
    end
    
    def authentication_params(*params)
      raise "Method deprecated. Please use signed_params instead."
    end

    def signed_params(verb, request_uri, params = {}, timestamp_str = nil)
      connection.signed_params(verb, request_uri, params, timestamp_str)
    end

    def connection
      raise "Not connected. Please connect! first." unless @connection
      @connection
    end
    
  end
end
