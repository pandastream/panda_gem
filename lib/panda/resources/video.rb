module Panda
  class Video < Resource
    
    def encodings
      EncodingScope.new(self)
    end
    
    class << self
      def method_missing(method_symbol, *arguments)
        VideoScope.new(self).send(method_symbol, *arguments)
      end
    end
    
    def reload
      super
      @encodings = nil
    end
    
  end
end
