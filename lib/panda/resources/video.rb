module Panda
  class Video < Resource
    has_many :encodings
  end  
end