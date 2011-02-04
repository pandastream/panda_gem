module Panda
  module Destroyers

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def delete(id)
        uri = json_path(create_rest_url(one_path,{:id =>id}))
        response = connection.delete(uri)
        response['deleted'] == 'ok'
      end
      
    end

    def delete
      uri = replace_pattern_with_self_variables(self.class.one_path)
      response = connection.delete(uri)
      !!response['deleted']
    end

  end
end