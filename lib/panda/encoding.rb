module Panda
  class Encoding < Base

    belongs_to :cloud
    belongs_to :video
    has_one :profile

    validate do
      !self.video_id.nil?
    end

    match "/videos/:video_id/encodings"
    
  end
end