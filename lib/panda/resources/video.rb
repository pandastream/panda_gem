module Panda
  class Video < Resource
    include ShortStatus
    
    def encodings
      EncodingScope.new(self)
    end
    
    class << self
      def method_missing(method_symbol, *args, &block)
        VideoScope.new(self).send(method_symbol, *args, &block)
      end
    end
    
    def reload
      super
      @encodings = nil
    end
    
  end
end
