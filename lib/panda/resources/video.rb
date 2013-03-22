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

    def create
      if self.file?
        session = create_upload_session(attributes.clone)
        load_response( upload_file(self.file, session['location']) )
      else
        super
      end
    end

    private

    def upload_file(body, url)
      body.rewind if body.respond_to?(:rewind)

      uri =  URI.parse(url)
      uploader = Panda::HttpClient.new("#{uri.scheme}://#{uri.host}:#{uri.port}")
      uploader.put(uri.path, body, uri.query, {'Content-Type' => 'application/octet-stream'})
    end

    def create_upload_session(session)
      file = session.delete('file')
      session['file_name'] = File.basename(file.path)
      session['file_size'] = file.size
      session['use_all_profiles'] = true unless self.use_all_profiles?

      connection.post('/videos/upload.json', session)
    end

    def get_url(end_path, https)
      "#{https ? cloud.https_url : cloud.url}#{end_path}"
    end

  end
end
