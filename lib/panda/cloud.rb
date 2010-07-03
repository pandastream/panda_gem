module Panda
  class Cloud < Base
    class << self
      
      def find(id)
        cloud = find_by_path(get_one_path, {:id => id})

        c = Panda.connection
        connection_params = {
          :access_key => c.access_key,
          :secret_key => c.secret_key,
          :api_host => c.api_host,
          :api_port => c.api_port,
          :cloud_id => cloud.id
        }
        
        cloud.connection = Panda::Connection.new(connection_params)
        cloud
      end

    end
    
    def videos
      Videos[connection]
    end
    
    def encodings
      Encoding[connection]
    end
    
    def profiles
      Profile[connection]
    end
    
  end
end
