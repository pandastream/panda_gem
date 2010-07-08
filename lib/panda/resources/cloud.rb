module Panda
  class Cloud < Base
    include Panda::Router
    include Panda::Updatable
    
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
        
        config = Panda.connection
        cloud.connection = Panda::Connection.new({
          :access_key => config.access_key,
          :secret_key => config.secret_key,
          :api_host => config.api_host,
          :api_port => config.api_port,
          :cloud_id => cloud.id
        })
        
        cloud
      end
      
      def connection
        Panda.connection
      end
      
    end
    
  end
end
