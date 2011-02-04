require 'faraday'
require 'yajl/json_gem'

module Panda
  module HttpClient
    class FaradayEngine
      
      def get(api_url, request_uri, params)
        connection = init_connection(api_url)
        rescue_json_parsing do
          response = connection.get do |req|
            req.url File.join(connection.path_prefix, request_uri), params
          end.body
        end
      end

      def post(api_url, request_uri, params)
        connection = init_connection(api_url)
        rescue_json_parsing do
          connection.post do |req|
            req.url File.join(connection.path_prefix, request_uri)
            req.body = params
          end.body
        end
      end

      def put(api_url, request_uri, params)
        connection = init_connection(api_url)
        rescue_json_parsing do
          connection.put do |req|
            req.url File.join(connection.path_prefix, request_uri)
            req.body = params
          end.body
        end
      end

      def delete(api_url, request_uri, params)
        connection = init_connection(api_url)
        rescue_json_parsing do
          connection.delete do |req|
            req.url File.join(connection.path_prefix, request_uri), params
          end.body
        end
      end
      
      private
      
      def init_connection(url)
        Faraday::Connection.new(:url => url) do |builder|
          builder.adapter faraday_adapter
          builder.response :yajl
        end
      end
      
      def faraday_adapter
        Faraday.default_adapter
      end
      
      
      def rescue_json_parsing(&block)
        begin
          yield
        rescue Faraday::Error::ParsingError => e
          raise ServiceNotAvailable.new
        end
      end
      
    end
  end
end