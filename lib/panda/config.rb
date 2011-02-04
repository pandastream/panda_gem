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
    
    def adapter(adapter_name)
      Panda.adapter = adapter_name
    end
    
    def adapter=(adapter_name)
      Panda.adapter = adapter_name
    end
        
    # Setup connection for Heroku
    def parse_panda_url(panda_url)
      panda_uri = URI.parse(panda_url)

      config['access_key'] = panda_uri.user
      config['secret_key'] = panda_uri.password
      config['cloud_id']   = panda_uri.path[1..-1]
      config['api_host']   = panda_uri.host
      config['api_port']   = API_PORT
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
