module Panda
  class Resource < Base
    attr_accessor :cloud
    
    include Panda::Finders
    include Panda::Builders
    include Panda::Associations
    include Panda::Connectable

    def initialize(attributes={})
      super(attributes)
      @cloud = self.class.cloud
    end
    
    def cloud_id
      cloud.id
    end
    
    def connection
      cloud.connection
    end
  end
end
