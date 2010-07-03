module Panda
  class Resource < Base
    
    def cloud_id
      connection.cloud_id
    end    
  end
end