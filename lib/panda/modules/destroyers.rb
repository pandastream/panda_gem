module Panda
  module Destroyers

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def delete(id)
        uri = create_rest_url(one_path,{:id =>id})
        response = connection.delete(uri)
        !!response['deleted']
      end
      
    end

    def delete
      uri = replace_pattern_with_self_variables(self.class.one_path)
      response = connection.delete(uri)
      !!response['deleted']
    end

  end
end