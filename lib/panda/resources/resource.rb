module Panda
  class Resource < Base

    include Panda::Builders
    include Panda::Associations

    def initialize(attributes={})
      super(attributes)
      @attributes['cloud_id'] ||= Panda.cloud.id
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
      load_response(response) ? (@changed_attributes = {}; true) : false
    end
    
    def create!
      create || errors.last.raise!
    end

    def reload
      raise "RecordNotFound" if new?
      perform_reload("cloud_id" => cloud_id)
    end
    
  end
end
