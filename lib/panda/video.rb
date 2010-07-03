module Panda
  class Video < Base

    def encodings
      @encodings ||= Encoding.find_all_by_video_id(id)
    end
    
  end
end