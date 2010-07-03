module Panda
  class Video < Base

    has_one :cloud

    def encodings
      @encodings ||= Encoding.find_all_by_video_id(id)
    end
    
  end
end