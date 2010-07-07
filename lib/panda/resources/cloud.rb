module Panda
  class Cloud < Base
    include Panda::Router
    attr_accessor :videos, :encodings, :profiles
    attr_accessor :connection
    
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
        cloud = find_by_path(one_path, {:id => id})
        
        c = Panda.connection
        cloud.connection = Panda::Connection.new({
          :access_key => c.access_key,
          :secret_key => c.secret_key,
          :api_host => c.api_host,
          :api_port => c.api_port,
          :cloud_id => cloud.id
        })
        
        cloud
      end
      
      def connect(connection)
        cloud = self.find(connection.cloud_id)
        cloud.connection = connection
        cloud
      end
      
      def connection
        Panda.connection
      end
      
    end
    
  end
end
