module Panda
  module Builders
    
    def self.included(base)
      base.extend(CreateBuilder)
      base.extend(DeleteBuilder)
    end
    
    module CreateBuilder
      
       def create(attributes)
         response = connection.post(full_object_url(many_path), attributes)
         Panda::const_get("#{name.split('::').last}").new(response)
       end

       def create!(attributes)
         create(attributes) || raise ("Blah")
       end
       
    end
    
    module DeleteBuilder
      def delete(id)
        response = connection.delete( full_object_url(object_url(one_path,{:id =>id}) ))
        response['deleted'] == 'ok'
      end
    end
    
  end
end