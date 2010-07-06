module Panda
  class Encoding < Resource

    belongs_to :cloud
    belongs_to :video
    has_one :profile

    def url
      "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{id}#{extname}"
    end

    def update; false; end
  
  end
end
