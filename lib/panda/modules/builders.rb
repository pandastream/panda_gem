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
      uri = replace_pattern_with_self_variables(self.class.many_path)
      response = connection.post(uri, attributes)
      load_and_reset(response)
    end

    def create!
      create || raise(errors.last)
    end

  end
end