module Panda
  class Resource < Base
    attr_accessor :cloud

    include Panda::Finders
    include Panda::Builders
    include Panda::Associations
    include Panda::Scoped

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
    
    def create
      raise "Can't create attribute. Already have an id=#{attributes['id']}" if attributes['id']
      response = connection.post(object_url_map(self.class.many_path), @attributes)
      load_response(response)
    end
    
    def create!
      create || errors.last.raise!
    end
    
  end
end
