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

    def preview_url(options={})
      default_options = {:https => false}
      options = default_options.merge(options)
      get_url("#{path}_1.jpg", options[:https]) if success?
    end

    def url(options={})
      default_options = {:https => false}
      options = default_options.merge(options)
      get_url("#{path}#{extname}", options[:https]) if success?
    end

    private

    def get_url(end_path, https)
      "#{https ? cloud.https_url : cloud.url}#{end_path}"
    end

  end
end
