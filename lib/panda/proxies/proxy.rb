module Panda
  class Proxy
    include Panda::Router::ClassMethods
    include Panda::Builders::ClassMethods
    
    include Panda::Finders::FindMany
    include Panda::Finders::FindOne

    include Panda::CloudConnection

    attr_accessor :parent, :klass

    def initialize(parent, klass)
      @parent = parent
      @klass = klass
    end

    def cloud
      @parent.is_a?(Cloud) ? @parent : @parent.cloud
    end

    def sti_name
      klass.sti_name
    end

  end
end
