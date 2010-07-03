module Panda
  class Encoding < Base

    has_one :cloud
    has_one :video
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