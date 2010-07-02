require 'restclient'
require 'json' unless defined?(ActiveSupport::JSON)

module Panda
  class << self
    attr_accessor :connection

    def configure(auth_params=nil)
      self.connection = Connection.new
      
      unless auth_params
        yield self.connection
      else 
        connect!(auth_params)
      end
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

    def connection
      raise "Not connected. Please connect! first." unless @connection
      @connection
    end

    def signed_params(verb, request_uri, params = {}, timestamp_str = nil)
      connection.signed_params(verb, request_uri, params, timestamp_str)
    end
    
  end
end
