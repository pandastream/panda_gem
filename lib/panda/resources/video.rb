module Panda
  class Video < Resource
    include ShortStatus
    has_many :encodings

    class << self
      def first
        VideoScope.new(self).per_page(1).first
      end
    end

  end
end
