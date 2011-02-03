require 'restclient'
require 'json' unless defined?(ActiveSupport::JSON) || defined?(JSON::JSON_LOADED)

module Panda
  module HttpClient
    class RestclientEngine

      def get(api_url, request_uri, params)
        rescue_json_parsing do
          connection = RestClient::Resource.new(api_url)
          query = ApiAuthentication.hash_to_query(params)
          hash_response connection[request_uri + '?' + query].get
        end
      end

      def post(api_url, request_uri, params)
        rescue_json_parsing do
          connection = RestClient::Resource.new(api_url)
          hash_response connection[request_uri].post(params)
        end
      end

      def put(api_url, request_uri, params)
        rescue_json_parsing do
          connection = RestClient::Resource.new(api_url)
          hash_response connection[request_uri].put(params)
        end
      end

      def delete(api_url, request_uri, params)
        rescue_json_parsing do
          connection = RestClient::Resource.new(api_url)
          query = ApiAuthentication.hash_to_query(params)
          hash_response connection[request_uri + '?' + query].delete
        end
      end

      private
      
      def hash_response(response)
        begin
          if defined?(ActiveSupport::JSON)
            ActiveSupport::JSON.decode(response)
          else
            JSON.parse(response)
          end
        rescue JSON::ParserError => e
          raise ServiceNotAvailable.new
        end
      end
      
      def rescue_json_parsing(&block)
        begin
          yield
        rescue RestClient::Exception => e
          hash_response(e.http_body)
        end
      end
      
    end
  end
end
    