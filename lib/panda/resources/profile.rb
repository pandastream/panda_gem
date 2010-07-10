module Panda
  class Profile < Resource
    include Panda::Updatable
    
    def encodings
      EncodingScope.new(self)
    end
    
  end
end