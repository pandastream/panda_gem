module Panda
  
  class Error < StandardError; end
  
  class APIError < Panda::Error
    def initialize(options)
      super("#{options['error']}: #{options['message']}")
    end
  end

  class ServiceNotAvailable < Panda::Error
    def initialize
      super("ServiceNotAvailable")
    end
  end

  class ConfigurationError < Panda::Error
    def initialize
      super("ConfigurationError")
    end
  end

end
