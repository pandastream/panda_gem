require 'restclient'
require 'forwardable'
require 'json' unless defined?(ActiveSupport::JSON)

module Panda
  class << self
    extend Forwardable
    
    attr_accessor :cloud, :clouds
    attr_writer :connection

    def_delegators :connection, :get, :post, :put, :delete, :api_url, :setup_bucket
    
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

    def signed_params(verb, request_uri, params = {}, timestamp_str = nil)
      connection.signed_params(verb, request_uri, params, timestamp_str)
    end

    def connection
      raise "Not connected. Please connect! first." unless @connection
      @connection
    end

  end
end
