module Panda
  class Profile < Resource
    include Panda::Updatable

    def encodings
      EncodingScope.new(self)
    end

    class << self
      def method_missing(method_symbol, *args, &block)
        Scope.new(self, Profile).send(method_symbol, *args, &block)
      end
    end

    def reload
      super
      @encodings = nil
    end
    
  end
end