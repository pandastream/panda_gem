module Panda
  class Encoding < Base
    match "/videos/:video_id/encodings"
    
    belongs_to :cloud
    belongs_to :video
    has_one :profile

    # validate do
    #   !self.video_id.nil?
    # end

    def url
      "http://s3.amazonaws.com/#{cloud.s3_videos_bucket}/#{id}#{extname}"
    end

    class << self
      def find(id)
        find_by_path("/encodings/:id", {:id => id})
      end
    end
    
  end
end