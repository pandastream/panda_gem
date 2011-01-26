module Panda
  class Video < Resource
    include ShortStatus
    has_many :encodings

    class << self
      def first
        VideoScope.new(self).per_page(1).first
      end
    end

    def screenshot
      "#{cloud.url}#{path}_1.jpg" if success? || nil
    end

  end
end
