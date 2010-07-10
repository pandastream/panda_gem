module Panda
  class Resource < Base

    include Panda::Builders
    include Panda::Associations

    def initialize(attributes={})
      super(attributes)
      @attributes['cloud_id'] = Panda.cloud.id
    end

    class << self
      include Panda::Finders::FindMany
      
      def cloud
        Panda.cloud
      end      
        
      def connection
        cloud.connection
      end
    end
    
    def cloud
      Panda.clouds[cloud_id]
    end
    
    def connection
      cloud.connection
    end
    
    def create
      raise "Can't create attribute. Already have an id=#{attributes['id']}" if attributes['id']
      response = connection.post(object_url_map(self.class.many_path), attributes)
      res = load_response(response)
      @changed_attributes = {}
      res
    end
    
    def create!
      create || errors.last.raise!
    end

    def reload
      raise "Record not found" if new?
      record_cloud_id = cloud_id
      record_id = id
      init_load
      @attributes['cloud_id'] = record_cloud_id
      perform_reload(record_id)
    end
    
  end
end
