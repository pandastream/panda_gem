require 'faraday'
require 'yajl/json_gem'

module Panda
  module Adapter
    class Faraday
      
      def initialize(api_url)
        @api_url = api_url
      end
      
      def get(request_uri, params)
        rescue_json_parsing do
          response = connection.get do |req|
            req.url File.join(connection.path_prefix, request_uri), params
          end.body
        end
      end

      def post(request_uri, params)
        # multipart upload
        if (f=params['file']) && f.is_a?(File)
          params['file'] = ::Faraday::UploadIO.new(f.path, 'multipart/form-data')
        end

        rescue_json_parsing do
          connection.post do |req|
            req.url File.join(connection.path_prefix, request_uri)
            req.body = params
          end.body
        end
      end

      def put(request_uri, params)
        rescue_json_parsing do
          connection.put do |req|
            req.url File.join(connection.path_prefix, request_uri)
            req.body = params
          end.body
        end
      end

      def delete(request_uri, params)
        rescue_json_parsing do
          connection.delete do |req|
            req.url File.join(connection.path_prefix, request_uri), params
          end.body
        end
      end
      
      private
      
      def connection
        @conn ||= ::Faraday::Connection.new(:url => @api_url) do |builder|
          builder.adapter :net_http
          builder.response :yajl
        end
      end
      
      def rescue_json_parsing(&block)
        begin
          yield || raise(ServiceNotAvailable)
        rescue ::Faraday::Error::ParsingError => e
          raise(ServiceNotAvailable)
        end
      end
      
    end
  end
end