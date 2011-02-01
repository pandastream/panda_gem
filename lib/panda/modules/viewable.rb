module Panda
  module Viewable
  
    def screenshots
      ((1..screenshots_size||0).map{|i| get_url("_#{i}.jpg")} if success?) || []
    end
  
    def url
      get_url("#{extname}") if success?
    end

    private

    def get_url(end_path)
      "#{cloud.url}#{path}#{end_path}"
    end

  end
end