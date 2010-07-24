module Panda
  class Cloud < Base
    include Panda::Updatable
    
    def initialize(attributes={})
      super(attributes)
      Panda.clouds[id] = self
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
    
    class << self
      include Panda::Finders::FindOne
      attr_reader :connection
      
      def find(id, options=nil)
        @connection = if options
          Connection.new(options.merge!(:cloud_id => id, :format => :hash))
        else
          Connection.new(Panda.connection.to_hash.merge!(:cloud_id => id))
        end
        super(id)
      end
    end
    
    def connection
      @connection ||= Connection.new(self.class.connection.to_hash.merge!(:cloud_id => id))
    end
    
    def reload
      super
      @videos_scope = nil
      @encodings_scope = nil
      @profiles_scope = nil
    end
    
  end
end
