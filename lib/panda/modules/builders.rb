module Panda
  module Builders
    
    def self.included(base)
      base.extend(CreateBuilder)
      base.extend(DeleteBuilder)
    end
    
    module CreateBuilder
      
       def create(attributes)
         if attr_id=(attributes[:id] || attributes['id'])
           raise "Can't create attribute. Already have an id=#{attr_id}"
         end
         
         response = connection.post(full_object_url(many_path), attributes)
         Panda::const_get("#{end_class_name}").new(response)
       end

       def create!(attributes)
         create(attributes) || raise(self.error.first.to_s)
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