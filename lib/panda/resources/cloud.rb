module Panda
  class Cloud < Base
    include Panda::Router
    include Panda::Updatable
    
    attr_accessor :videos, :encodings, :profiles
    attr_writer :connection
    
    def initialize(attributes={})
      super(attributes)

      # proxies
      @videos = Video[self]
      @encodings = Encoding[self]
      @profiles = Profile[self]
    end
    
    class << self      
      include Panda::Finders::PathFinder
      
      def find(id)
        find_by_path(one_path, {:id => id})
      end
      
      def connection
        Panda.connection
      end
    end
    
    def connection
      @connection ||= Connection.new(self.class.connection.to_hash.merge!(:cloud_id => id))
    end
    
  end
end
