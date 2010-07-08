module Panda
  module Scoped
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def cloud
        Panda.cloud
      end      
  
      def [](cloud)
        Scope.new(nil, name.to_s[0..-1].split('::').last.capitalize, cloud)
      end
      
      def connection
        cloud.connection
      end
      
    end
    
  end
end