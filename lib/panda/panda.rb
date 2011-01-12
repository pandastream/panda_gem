require 'forwardable'

module Panda

  extend self
  extend Forwardable

  attr_reader :cloud, :clouds
  attr_reader :connection, :config

  def_delegators :connection, :get, :post, :put, :delete, :api_url, :setup_bucket, :signed_params

  def configure(auth_params=nil, &block)

    if !auth_params
      @config = configure = Config.new
      if (block.arity > 0)
        block.call(configure)
      else
        configure.instance_eval(&block)
      end
      
      auth_params = configure.to_hash
    end

    configure_with_auth_params(auth_params)
  end

  def configure_heroku(heroku_url=nil)
    configure_with_auth_params Config.new.heroku(heroku_url)
  end

  def connect!(auth_params)
    @connection = Connection.new(auth_params)
  end

  def connection
    raise "Not connected. Please connect! first." unless @connection
    @connection
  end

  def http_client=(http_client_name)
    @http_client = Panda::HttpClients.const_get("#{http_client_name.to_s.capitalize}Engine").new
  end

  def http_client
    @http_client ||= Panda::HttpClients::RestclientEngine.new
  end

  private
  
  def configure_with_auth_params(auth_params)
    connect!(auth_params)
    @clouds = {}
    @cloud = Cloud::new(:id => @connection.cloud_id)
  end
  
end
