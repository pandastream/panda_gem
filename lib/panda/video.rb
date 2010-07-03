module Panda
  class Video < Base
    has_one :cloud
    has_many :encodings
  end
end