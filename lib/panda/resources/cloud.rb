module Panda
  class Cloud < Base
    include Panda::Updatable
    
    def initialize(attributes={})
      super(attributes)
      Panda.clouds[id] = self
    end
    
    def videos
      @videos_scope ||= VideoScope.new(self)
    end
    
    def encodings
      @encodings_scope ||= EncodingScope.new(self)
    end
    
    def profiles
      @profiles_scope ||= Scope.new(self, Profile)
    end
    
    class << self
      include Panda::Finders::FindOne
      
      def connection
        Panda.connection
      end
    end
    
    def connection
      @connection ||= Connection.new(self.class.connection.to_hash.merge!(:cloud_id => id))
    end
    
  end
end
