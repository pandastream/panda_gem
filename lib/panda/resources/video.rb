module Panda
  class Video < Resource
    has_many :encodings
    
    def update; false; end
    
  end  
end