module Panda
  module Builders

    def self.included(base)
      base.extend(CreateBuilder)
      base.extend(DeleteBuilder)
    end

    module CreateBuilder

      def create(attributes)       
       resource = build_resource(attributes)
       resource.create
       resource
      end

      def create!(attributes)
        resource = build_resource(attributes)
        resource.create!
        resource
      end

      private
      def build_resource(attributes)
        Panda::const_get("#{end_class_name}").new(attributes.merge(:cloud_id => cloud.id))
      end
    end

    module DeleteBuilder
      def delete(id)
        response = connection.delete(full_object_url(object_url(one_path,{:id =>id})))
        response['deleted'] == 'ok'
      end
    end

  end
end