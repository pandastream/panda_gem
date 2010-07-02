module Panda
  class Video < Base
    class << self
      def path
        "/videos"
      end
    end
    
    def initialize(attrs={})
      super(attrs)
    end
    
  end
end