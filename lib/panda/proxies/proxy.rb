module Panda
  class Proxy
    include Panda::Router::ClassMethods
    include Panda::Finders::FindMany
    include Panda::Finders::FindOne
    include Panda::Builders::CreateBuilder
    include Panda::CloudConnection

    attr_accessor :parent, :klass

    def initialize(parent, klass)
      @parent = parent
      @klass = klass
    end

    def cloud
      @parent.is_a?(Cloud) ? @parent : @parent.cloud
    end

    def end_class_name
      klass.end_class_name
    end

  end
end
