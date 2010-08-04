module Panda
  class Video < Resource
    include ShortStatus
    
    def encodings
      @encodings ||= EncodingScope.new(self)
    end
    
    class << self
      def method_missing(method_symbol, *args, &block)
        scope = VideoScope.new(self)
        if scope.respond_to?(method_symbol)
           scope.send(method_symbol, *args, &block)
        else
          super
        end
      end

      def first
        VideoScope.new(self).per_page(1).first
      end
    end

    def reload
      @encodings = nil
      super
    end

  end
end
