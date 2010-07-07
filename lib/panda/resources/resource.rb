module Panda
  class Resource < Base
    
    def cloud_id
      connection.cloud_id
    end
    
    class << self 
      
      def delete(id)
        new({:id => id}).delete
      end
      
    end
    
    def delete
      response = connection.delete(element_url_map(self.class.one_path))
      response['deleted'] == 'ok'
    end
        
  end
end