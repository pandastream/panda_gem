module Panda
  module Destroyers

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def delete(id)
        response = connection.delete(full_object_url(object_url(one_path,{:id =>id})))
        response['deleted'] == 'ok'
      end
      
    end

    def delete
      response = connection.delete(object_url_map(self.class.one_path))
      !!response['deleted']
    end

  end
end