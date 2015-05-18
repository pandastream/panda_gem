CHUNK_SIZE = 100 * 1024 # 5 * 1024 * 1024

class File
  def each_chunk_with_index()
    i = 0
    until eof?
      yield(read(CHUNK_SIZE), i)
      i = i+1
    end
  end
end

module Panda
  class UploadSession
    attr_reader :location, :status, :video, :error_message, :file_name, :file_size

    def initialize(file_name, options={})
      @file_name = file_name
      @file_size = File.size(file_name)
      params = { 
        :file_size => @file_size,
        :file_name => @file_name,
      }.merge(options)

      data = Panda.post("/videos/upload.json", params)
      @location = URI.parse(data["location"])  
      @status = "initialized"
      @video = nil
      @error_message = nil
    end

    def start(pos=0)
      if @status == "initialized"
        @status = "uploading"
        open(@file_name, "rb") do |f|
          f.seek(pos)
          f.each_chunk_with_index() { |chunk, i|
            begin
              index = i * CHUNK_SIZE
                uri = URI.parse(URI.encode(@location.to_s))
                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
            
                request = Net::HTTP::Post.new(uri.request_uri, initheader = {
                  'Content-Type' =>'application/octet-stream',
                  'Cache-Control' => 'no-cache',
                  'Content-Range' => "bytes #{pos+index}-#{pos+index+CHUNK_SIZE-1}/#{@file_size}",
                  'Content-Length' => "#{CHUNK_SIZE}"
                })
                request.body = chunk
  
                response = https.request(request)
                if response.code == '200'
                  @status = "uploaded"
                  @video = Panda::Video.new(JSON.parse(response.body))
                elsif response.code != '204'
                  @statys = "error"
                  break  
                end 
            rescue Exception => e
              @status = "error"
              @error_mesage = e.message
              raise e
            end 
          }
        end
      else
        raise "Already started"
      end
    end

    def resume()
      if @status != "uploaded"
        uri = URI.parse(URI.encode(@location.to_s))
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
    
        request = Net::HTTP::Post.new(uri.request_uri, initheader = {
          'Content-Type' =>'application/octet-stream',
          'Cache-Control' => 'no-cache',
          'Content-Range' => "bytes */#{@file_size}",
          'Content-Length' => "0"
        })
        response = https.request(request)
        pos = response["Range"].split("-")[1]
        @status = "initialized"
        self.start(pos.to_i)
      else
        raise ("Already succeed")
      end
    end

    def abort()
      if @status != "success"
        @status = "aborted"
        @error_message = nil
      else
        raise "Already succeed"
      end
    end
  end
end
