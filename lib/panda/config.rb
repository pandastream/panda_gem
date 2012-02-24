require 'uri'

module Panda
  class Config

    def self.from_panda_url(panda_url)
      panda_uri = URI.parse(panda_url)

      config = new
      config.access_key = panda_uri.user
      config.secret_key = panda_uri.password
      config.cloud_id   = panda_uri.path[1..-1]
      config.api_host   = panda_uri.host
      config.api_port   = panda_uri.port
      config
    end

    def self.from_hash(auth_params)
      config = new
      auth_params.each_key do |key|
        config.send("#{key}=", auth_params[key])
      end
      config
    end

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

    def validate!
      errs = validation_errors
      raise Panda::ConfigurationError, errs.join(', ') if errs.any?
      true
    end

    def valid?
      validation_errors.empty?
    end

    def validation_errors
      err = []
      if config["access_key"].to_s.empty?
        err << "access_key is missing"
      end
      if config["secret_key"].to_s.empty?
        err << "secret_key is missing"
      end
      err
    end

  end
end
