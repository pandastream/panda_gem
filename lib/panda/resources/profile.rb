module Panda
  class Profile < Resource
    include Panda::Updatable

    def encodings
      EncodingScope.new(self)
    end

    class << self
      def method_missing(method_symbol, *args, &block)
        scope = Scope.new(Profile,self)
        if scope.really_respond_to?(method_symbol)
          scope.send(method_symbol, *args, &block)
        else
          super
        end
      end
    end

    def reload
      super
      @encodings = nil
    end
    
  end
end