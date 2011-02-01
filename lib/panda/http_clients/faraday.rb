require 'faraday'
require 'yajl'

module Panda
  module HttpClient
    class FaradayEngine
      
      def get(api_url, request_uri, params)
        connection = init_connection(api_url)
        response = connection.get do |req|
          req.url File.join(connection.path_prefix, request_uri), params
        end.body
      end

      def post(api_url, request_uri, params)
        connection = init_connection(api_url)
        connection.post do |req|
          req.url File.join(connection.path_prefix, request_uri)
          req.body = params
        end.body
      end

      def put(api_url, request_uri, params)
        connection = init_connection(api_url)
        connection.put do |req|
          req.url File.join(connection.path_prefix, request_uri)
          req.body = params
        end.body
      end

      def delete(api_url, request_uri, params)
        connection = init_connection(api_url)
        connection.delete do |req|
          req.url File.join(connection.path_prefix, request_uri), params
        end.body
      end
      
      private
      
      def init_connection(url)
        @conn ||= Faraday::Connection.new(:url => url) do |builder|
          builder.adapter Faraday.default_adapter
          builder.response :yajl
        end
      end
      
    end
  end
end