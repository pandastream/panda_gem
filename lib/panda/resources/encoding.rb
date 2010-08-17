module Panda
  class Encoding < Resource
    include ShortStatus

    belongs_to :video
    has_one :profile

    def url
      get_url("#{id}#{extname}")
    end

    def screenshots
      ((1..7).map{|i| get_url("#{id}_#{i}.jpg")} if success?) || []
    end

    class << self
      def first
        EncodingScope.new(self).per_page(1).first
      end
    end

    private
    def get_url(filename)
      "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{filename}"
    end
    
  end
end