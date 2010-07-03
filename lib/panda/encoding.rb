module Panda
  class Encoding < Base

    has_one :cloud
    has_one :video
    has_one :profile

    class << self
      def path
        "/videos/:video_id/encodings"
      end
      
      def find_all_by_video_id(id)
        find_by_path(get_one_path, {:video_id => id})
      end
    end

    def cloud_id
      Panda.connection.cloud_id
    end
  end

end