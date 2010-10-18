module Panda
  class Encoding < Resource
    include ShortStatus

    belongs_to :video
    has_one :profile

    class << self
      def first
        EncodingScope.new(self).per_page(1).first
      end
    end

    def url
      get_url("#{extname}")
    end

    def error_log
      get_url(".log") if fail?
    end
    
    def screenshots
      ((1..7).map{|i| get_url("_#{i}.jpg")} if success?) || []
    end

    private

    def get_url(end_path)
      "#{cloud.url}#{path}#{end_path}"
    end

  end
end