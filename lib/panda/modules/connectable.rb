module Panda
  module Connectable
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def cloud
        @cloud || Panda.cloud
      end      
  
      def cloud=(cloud)
        @cloud = cloud
      end
    
      def [](cloud)
        FinderProxy.new(name, cloud)
      end
      
      def connection
        cloud.connection
      end
      
    end
    
  end
end