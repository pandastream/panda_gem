require 'faraday'
require 'multi_json'

module Panda
  module HttpClient
    class Faraday
      
      def initialize(api_url)
        @api_url = api_url
      end
      
      def get(request_uri, params)
        rescue_json_parsing do
          connection.get do |req|
            req.url File.join(connection.path_prefix, request_uri), params
          end.body
        end
      end

      def post(request_uri, params)
        # multipart upload
        params['file'] = ::Faraday::UploadIO.new(params['file'], 'multipart/form-data') if params['file']

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
        @conn ||= ::Faraday.new(:url => @api_url) do |builder|
          builder.request :multipart
          builder.request :url_encoded
          builder.adapter Panda.default_adapter
        end
      end

      def rescue_json_parsing(&block)
        begin
          data = yield
          MultiJson.load(data)
        rescue MultiJson::DecodeError
          raise ServiceNotAvailable, data
        end
      end
      
    end
  end
end

if defined?(Typhoeus)
  Panda.default_adapter = :typhoeus
elsif defined?(Excon)
  Panda.default_adapter = :excon
elsif defined?(Patron)
  Panda.default_adapter = :patron
elsif defined?(NetHttpPersistent)
  Panda.default_adapter = :net_http_persisten
else
  Panda.default_adapter = :net_http
end