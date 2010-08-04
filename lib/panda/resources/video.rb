module Panda
  class Video < Resource
    include ShortStatus
    
    def encodings
      @encodings ||= EncodingScope.new(self)
    end
    
    class << self
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
