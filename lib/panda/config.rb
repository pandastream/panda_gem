require 'uri'

module Panda
  class Config
    
    def config
      @config ||= {}
    end
    
    [:api_host, :api_port, 
     :access_key, :secret_key, 
     :api_version, :cloud_id].each do |attr|
      define_method "#{attr}" do |value|
        config["#{attr.to_s}"] = value
      end

      define_method "#{attr}=" do |value|
        config["#{attr.to_s}"] = value
      end
    end
    
    def to_hash
      config
    end
    
    def http_client(http_client_name)
      Panda.http_client = http_client_name
    end
    
    def http_client=(http_client_name)
      Panda.http_client = http_client_name
    end
    
    #shortcuts
    
    def key(val)
      config['access_key'] = val
    end
    
    def secret(val)
      config['secret_key'] = val
    end
    
    # Setup connection for Heroku
    def heroku(heroku_url=nil)
      heroku_uri = URI.parse(heroku_url || ENV['PANDASTREAM_URL'])

      config['access_key'] = heroku_uri.user
      config['secret_key'] = heroku_uri.password
      config['cloud_id']   = heroku_uri.path[1..-1]
      config['api_host']   = heroku_uri.host
      config['api_port']   = heroku_uri.port
      config
    end
    
    # Set the correct api_host for US/EU
    def region(region)
      if(region.to_s == 'us')
        config['api_host'] = US_API_HOST
      elsif(region.to_s == 'eu')
        config['api_host'] = EU_API_HOST
      else
        raise "Region Unknown"
      end
    end
    
  end
end
