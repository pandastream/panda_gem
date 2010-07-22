module Panda
  class Encoding < Resource
    belongs_to :video
    has_one :profile

    def url
      "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{id}#{extname}"
    end

    def screenshots
      @screenshots ||=
        if status == 'success'
          (1..7).map do |i|
            "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{id}_#{i}.jpg"
          end
        else
          []
        end
    end
    
    class << self
      def method_missing(method_symbol, *args, &block)
        EncodingScope.new(self).send(method_symbol, *args, &block)
      end
    end
    
    def reload
      super
      @profile = nil
      @video = nil
    end
    
  end
end