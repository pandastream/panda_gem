module Panda
  class Video < Resource
    include VideoState
    include Viewable
    has_many :encodings

    class << self
      def first
        VideoScope.new(self).per_page(1).first
      end
    end

    def screenshots_size; 1 end
    
  end
end
