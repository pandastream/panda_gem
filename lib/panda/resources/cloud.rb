module Panda
  class Cloud < Base
    include Panda::Updatable
    attr_reader :connection
    
    def initialize(attributes={})
      super(attributes)
      @connection = Connection.new(Panda.connection.to_hash.merge!(:cloud_id => id, :format => :hash))
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
      @videos_scope = VideoScope.new(self)
    end

    def encodings
      @encodings_scope = EncodingScope.new(self)
    end

    def profiles
      @profiles_scope = Scope.new(self, Profile)
    end

    def reload
      super
      @videos_scope = nil
      @encodings_scope = nil
      @profiles_scope = nil
    end

    def method_missing(method_symbol, *arguments)
      # Lazy load the cloud
      @found ||= reload
      super
    end

  end
end
