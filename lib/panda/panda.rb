module Panda

  extend self
  extend Forwardable

  attr_reader :cloud, :clouds
  attr_reader :connection

  def_delegators :connection, :get, :post, :put, :delete, :api_url, :setup_bucket, :signed_params

  def configure(auth_params=nil, &block)

    if !auth_params
      configure = Config.new
      if (block.arity > 0)
        block.call(configure)
      else
        configure.instance_eval(&block)
      end
      
      auth_params = configure.to_hash
    elsif auth_params.is_a?(String)
      auth_params = Config.new.parse_panda_url(auth_params)
    end

    configure_with_auth_params(auth_params)
    true
  end

  def configure_heroku
    configure_with_auth_params Config.new.parse_panda_url(ENV['PANDASTREAM_URL'])
    true
  end

  def connect!(auth_params)
    @connection = Connection.new(auth_params)
  end

  def connection
    raise "Panda is not configured!" unless @connection
    @connection
  end

  def adapter=(klass)
    @adapter_class = klass
  end

  def adapter
    @adapter_class ||= default_adapter
  end
  
  private

  def default_adapter
    Panda::Adapter::RestClient
  end
  
  def configure_with_auth_params(auth_params)
    connect!(auth_params)
    @clouds = {}
    @cloud = Cloud::new(:id => @connection.cloud_id)
  end
  
end
