require 'restclient'
require 'forwardable'
require 'json' unless defined?(ActiveSupport::JSON)

module Panda
  extend self
  extend Forwardable

  attr_reader :cloud, :clouds
  attr_reader :connection

  def_delegators :connection, :get, :post, :put, :delete, :api_url, :setup_bucket, :signed_params

  def configure(auth_params=nil)
    @clouds = {}

    if auth_params
      connect!(auth_params)
    else
      yield @connection = Connection.new
    end

    @connection.raise_error=true
    @connection.format = :hash
    @cloud = Cloud::new(:id => @connection.cloud_id)
  end

  def connect!(auth_params, options={})
    @connection = Connection.new(auth_params, options)
  end

  def connection
    raise "Not connected. Please connect! first." unless @connection
    @connection
  end

  def version
    open(File.join(File.dirname(__FILE__), '../../VERSION')) { |f|
      f.read.strip
    }
  end

end
