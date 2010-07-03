module Panda
  class Encoding < Base

    belongs_to :cloud
    belongs_to :video
    has_one :profile

    match "/videos/:video_id/encodings"
        
  end
end