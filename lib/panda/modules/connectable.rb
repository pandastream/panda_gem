module Panda
  module Connectable
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def connection 
        @connection ||= Panda.connection
      end      
  
      def connection=(c)
        @connection = c
      end
    
      def [](connection)
        new_clone = self.clone!
        new_clone.connection = connection
        new_clone
      end
    end
    
  end
end