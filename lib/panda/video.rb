module Panda
  class Video < Base
    belongs_to :cloud
    has_many :encodings
  end
end