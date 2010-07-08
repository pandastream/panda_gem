module Panda
  class Encoding < Resource
    belongs_to :video
    has_one :profile

    def url
      "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{id}#{extname}"
    end

    def screenshots
      @screenshots ||= (1..7).map do |i|
        "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{id}_#{i}.jpg"
      end
    end
    
  end
end
