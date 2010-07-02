module Panda
  class Encoding < Base
    class << self
      def path
        "/videos/:video_id/encodings"
      end
      
      def find_all_by_video_id(id)
        find_by_path(index_path, {:video_id => id})
      end
      
    end
    
  end
end