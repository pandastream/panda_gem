module Panda
  class Cloud < Base
    include Panda::Updatable
    attr_reader :connection

    def initialize(attributes={})
      super(attributes)
      connection_params = Panda.connection.to_hash.merge!(:cloud_id => id, :format => :hash)
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

    def videos
      VideoScope.new(self)
    end

    def encodings
      EncodingScope.new(self)
    end

    def profiles
      ProfileScope.new(self)
    end

    def lazy_load
      @found ||= reload
    end
    
    def method_missing(method_symbol, *arguments)
      lazy_load
      super
    end

  end
end
