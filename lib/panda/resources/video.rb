module Panda
  class Video < Resource
    include VideoState
    has_many :encodings

    class << self
      def first
        VideoScope.new(self).per_page(1).first
      end
    end

    def metadata
      connection.get("/videos/#{id}/metadata.json")
    end

    def preview_url
      get_url("#{path}_1.jpg") if success?
    end

    def url
      get_url("#{path}#{extname}") if success?
    end

    private

    def get_url(end_path)
      "#{cloud.url}#{end_path}"
    end

  end
end
