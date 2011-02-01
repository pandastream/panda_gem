module Panda
  module Builders

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def create(attributes={})
       resource = build_resource(attributes)
       yield resource if block_given?

       resource.create
       resource
      end

      def create!(attributes={})
        resource = build_resource(attributes)
        yield resource if block_given?

        resource.create!
        resource
      end

      private
      
      def build_resource(attributes)
        Panda::const_get("#{sti_name}").new(attributes.merge(:cloud_id => cloud.id))
      end
    end

    def create
      raise "Can't create attribute. Already have an id=#{attributes['id']}" if attributes['id']
      response = connection.post(object_url_map(self.class.many_path), attributes)
      load_and_reset(response)
    end

    def create!
      create || errors.last.raise!
    end

  end
end