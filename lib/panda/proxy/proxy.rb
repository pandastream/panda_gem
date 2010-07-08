module Panda
  class Proxy
    include Panda::Router::ClassMethods
  
    attr_accessor :target, :kclass, :cloud
    attr_writer :connection
  
    def connection
      @cloud.connection
    end
  
    def name
      kclass
    end
  
  end
end
