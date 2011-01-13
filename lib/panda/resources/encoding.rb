module Panda
  class Encoding < Resource
    include VideoState
    include Viewable
    
    belongs_to :video
    has_one :profile

    class << self
      def first
        EncodingScope.new(self).per_page(1).first
      end
    end

    def screenshots_size; 7 end
    
  end
end