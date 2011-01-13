module Panda
  module VideoState
    def success?
      @attributes['status'] == 'success'
    end

    def processing?
      @attributes['status'] == 'processing'
    end

    def fail?
      @attributes['status'] == 'fail'
    end
    
    def error_message
      @attributes['error_message']
    end
   
    def error_class
      @attributes['error_class']
    end
    
  end
end