module Panda
  class Proxy
    include Panda::Router::ClassMethods
    include Panda::Finders::FindMany
    include Panda::Finders::FindOne
    include Panda::Builders::CreateBuilder
  
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
