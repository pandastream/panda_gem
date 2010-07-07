module Panda
  class Resource < Base
    include Panda::Finders
    include Panda::Associations
    
    
    def cloud_id
      connection.cloud_id
    end
    
    class << self
      def delete(id)
        new({:id => id}).delete
      end
    end

  end
end