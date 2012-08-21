require 'restclient'

module Panda
  module Adapter
    class RestClient
      
      def initialize(api_url)
        @api_url = api_url
      end
      
      def get(request_uri, params)
        rescue_json_parsing do
          query = ApiAuthentication.hash_to_query(params)
          connection[request_uri + '?' + query].get
        end
      end

      def post(request_uri, params)
        rescue_json_parsing do
          connection[request_uri].post(params)
        end
      end

      def put(request_uri, params)
        rescue_json_parsing do
          connection[request_uri].put(params)
        end
      end

      def delete(request_uri, params)
        rescue_json_parsing do
          query = ApiAuthentication.hash_to_query(params)
          connection[request_uri + '?' + query].delete
        end
      end

      private

      def connection
        @conn ||= ::RestClient::Resource.new(@api_url)
      end

      def rescue_json_parsing(&block)
        begin
          MultiJson.load(yield)
        rescue MultiJson::DecodeError
          raise(ServiceNotAvailable)
        end
      end

    end
  end
end

Panda.adapter = Panda::Adapter::RestClient
