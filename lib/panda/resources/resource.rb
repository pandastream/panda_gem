module Panda
  class Resource < Base
    include Panda::Finders
    include Panda::Associations
    
    
    def cloud_id
      connection.cloud_id
    end
  end
end