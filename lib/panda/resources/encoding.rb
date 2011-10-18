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

    def url
      full_path = "#{path}#{extname}"
      get_url(full_path) if files.include?(full_path)
    end
    
    def urls
      files.map {|f| "#{cloud.url}#{f}"}
    end

    def screenshots
      ((1..7).map{|i| get_url("#{path}_#{i}.jpg")} if success?) || []
    end

    def cancel
      connection.post("/encodings/#{id}/cancel.json")['canceled']
    end

    def retry
      connection.post("/encodings/#{id}/retry.json")['retried']
    end

    private

    def get_url(end_path)
      "#{cloud.url}#{end_path}"
    end
  end
end