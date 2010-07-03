module Panda
  class Error
    attr_reader :message
    attr_reader :error_class
    attr_reader :original_hash
    
    def initialize(options)
     @original_hash = options
     @message = options['message']
     @error_class = options['error']
    end
    
    def raise!
      raise(self.to_s)
    end
    
    def to_s
      "#{@error_class}: #{@message}"
    end
    
  end
end