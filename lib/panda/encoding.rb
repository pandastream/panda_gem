module Panda
  class Encoding < Base

    belongs_to :cloud
    belongs_to :video
    has_one :profile

    match "/videos/:video_id/encodings"
    
    class << self
      def path
        "/videos/:video_id/encodings"
      end      
    end

    def cloud_id
      Panda.connection.cloud_id
    end
  end

end