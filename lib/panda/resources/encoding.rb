module Panda
  class Encoding < Resource
    include VideoState

    belongs_to :video
    has_one :profile

    class << self
      def first
        EncodingScope.new(self).per_page(1).first
      end
    end

    def url(options={})
      default_options = {:https => false}
      options = default_options.merge(options)
      full_path = "#{path}#{extname}"
      get_url(full_path, options[:https]) if files.include?(full_path)
    end
    
    def urls(options={})
      default_options = {:https => false}
      options = default_options.merge(options)
      files.map {|f| get_url(f, options[:https])}
    end

    def screenshots(options={})
      default_options = {:https => false}
      options = default_options.merge(options)
      ((1..7).map{|i| get_url("#{path}_#{i}.jpg", options[:https])} if success?) || []
    end

    def cancel
      connection.post("/encodings/#{id}/cancel.json")['canceled']
    end

    def retry
      connection.post("/encodings/#{id}/retry.json")['retried']
    end

    private

    def get_url(end_path, https)
      "#{https ? cloud.https_url : cloud.url}#{end_path}"
    end
  end
end