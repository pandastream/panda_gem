module Panda
  class Profile < Base
    
    class << self
      def path
        "/profiles"
      end
    end
    
    def encodings
      @encodings ||= Encoding.find_all_by_profile_id(id)
    end
      
    def initialize(attrs={})
      super(attrs)
    end
    
  end
end