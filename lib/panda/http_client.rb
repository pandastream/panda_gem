require 'excon'
require 'multi_json'

module Panda
  class HttpClient

      def initialize(api_url)
        @api_url = api_url
      end

      def get(path, query="", headers={})
        json_response do
          connection.request(:method => :get, :path => path, :query => query, :headers => headers).body
        end
      end

      def post(path, body, query="", headers={})
        json_response do
          connection.request(:method => :post, :path => path, :query => query, :body => body, :headers => headers).body
        end
      end

      def put(path, body, query="", headers={})
        json_response do
          connection.request(:method => :put, :path => path, :query => query, :body => body, :headers => headers).body
        end
      end

      def delete(path, query="", headers={})
        json_response do
          connection.request(:method => :delete, :path => path, :query => query, :headers => headers).body
        end
      end

      private

      def connection
        @connection = Excon.new(@api_url)
      end

      def json_response(&block)
        begin
          data = yield
          Panda.load_json(data)
        rescue MultiJson::DecodeError
          raise ServiceNotAvailable, data
        end
      end

  end
end
