module Panda
  class Resource < Base
    match "/#{self.name.split('::').last.downcase}s"
    
    def cloud_id
      connection.cloud_id
    end    
  end
end