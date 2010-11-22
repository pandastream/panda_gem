module Panda
  class Cloud < Base
    include Panda::Updatable
    attr_reader :connection

    def initialize(attributes={})
      super(attributes)
      connection_params = Panda.connection.to_hash.merge!(:cloud_id => id)
      @connection = Connection.new(connection_params)
      Panda.clouds[id] = self
    end

    class << self
      include Panda::Finders::FindOne

      def find(id, options=nil)
        super(id)
      end

      def connection
        Panda.connection
      end
    end

    def eu?
      region == "eu"
    end

    def us?
      region == "us"
    end

    def region
      return "eu" if connection.api_host == Panda::EU_API_HOST
      return "us" if connection.api_host == Panda::US_API_HOST
    end

    def videos
      VideoScope.new(self)
    end

    def encodings
      EncodingScope.new(self)
    end

    def profiles
      ProfileScope.new(self)
    end

    def method_missing(method_symbol, *arguments)
      lazy_load
      super
    end

    private

    def lazy_load
      @found ||= reload
    end

  end
end
