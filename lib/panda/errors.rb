module Panda
  
  class Error < StandardError; end
  
  class APIError < Panda::Error
    def initialize(options)
      super("#{options['error']}: #{options['message']}")
    end
  end

  class ServiceNotAvailable < Panda::Error
  end

  class ConfigurationError < Panda::Error
  end

end
