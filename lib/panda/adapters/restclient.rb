require 'restclient'
require 'json' unless defined?(ActiveSupport::JSON) || defined?(JSON::JSON_LOADED)

module Panda
  module Adapter
    class RestClient
      
      def initialize(api_url)
        @api_url = api_url
      end
      
      def get(request_uri, params)
        rescue_json_parsing do
          query = ApiAuthentication.hash_to_query(params)
          hash_response connection[request_uri + '?' + query].get
        end
      end

      def post(request_uri, params)
        rescue_json_parsing do
          hash_response connection[request_uri].post(params)
        end
      end

      def put(request_uri, params)
        rescue_json_parsing do
          hash_response connection[request_uri].put(params)
        end
      end

      def delete(request_uri, params)
        rescue_json_parsing do
          query = ApiAuthentication.hash_to_query(params)
          hash_response connection[request_uri + '?' + query].delete
        end
      end

      private
      
      def connection
        @conn ||= ::RestClient::Resource.new(@api_url)
      end
      
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
        rescue ::RestClient::Exception => e
          hash_response(e.http_body)
        end
      end
      
    end
  end
end
    