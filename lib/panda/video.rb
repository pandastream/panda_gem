module Panda
  class Video < Resource
    belongs_to :cloud
    has_many :encodings
  end
end