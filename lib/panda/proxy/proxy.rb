module Panda
  class Proxy
    include Panda::Router::ClassMethods
    include Panda::Finders::FindMany
    include Panda::Finders::FindOne
    include Panda::Builders::CreateBuilder
  
    attr_accessor :parent, :klass
  
    def connection
      @cloud.connection
    end
  
    def end_name
      klass.end_name
    end
  
  end
end
