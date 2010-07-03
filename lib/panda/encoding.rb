module Panda
  class Encoding < Base
    
    belongs_to :cloud
    belongs_to :video
    has_one :profile

    # validate do
    #   !self.video_id.nil?
    # end

    def url
      "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{id}#{extname}"
    end
   
  end
end