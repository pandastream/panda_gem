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
    elsif auth_params.is_a?(String)
      auth_params = Config.new.heroku(auth_params)
    end

    configure_with_auth_params(auth_params)
    true
  end

  def configure_heroku(heroku_url=nil)
    configure_with_auth_params Config.new.heroku(heroku_url)
    true
  end

  def connect!(auth_params)
    @connection = Connection.new(auth_params)
  end

  def connection
    raise "Panda is not configured!" unless @connection
    @connection
  end

  def http_client=(http_client_name)
    if File.exists?((local_lib=
        "#{File.dirname(__FILE__)}/http_clients/#{http_client_name}") + '.rb')
      require local_lib
    end
    
    @http_client = Panda::HttpClient.const_get("#{http_client_name.to_s.capitalize}Engine").new
  end

  def http_client
    @http_client ||= default_engine
  end
  
  private

  def default_engine
    require "panda/http_clients/restclient"
    Panda::HttpClient::RestclientEngine.new
  end
  
  def configure_with_auth_params(auth_params)
    connect!(auth_params)
    @clouds = {}
    @cloud = Cloud::new(:id => @connection.cloud_id)
  end
  
end
