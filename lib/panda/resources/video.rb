module Panda
  class Video < Resource
    include ShortStatus
    
    def encodings
      @encodings ||= EncodingScope.new(self)
    end
    
    class << self
      def method_missing(method_symbol, *args, &block)
        if respond_to?(method_symbol)
          VideoScope.new(self).send(method_symbol, *args, &block)
        else
          super
        end
      end

      def first
        VideoScope.new(self).per_page(1).first
      end

      def respond_to?(method)
        super || VideoScope.new(self).respond_to?(method)
      end
    end

    def reload
      @encodings = nil
      super
    end

  end
end
