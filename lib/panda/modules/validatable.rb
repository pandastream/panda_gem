class Proc
  def bind(other)
    return Proc.new do
      other.instance_eval(&self)
    end
  end
end

module Panda
  module Validatable
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def validations
        @validations.to_a
      end
      
      def validate(&block)
        if block_given?
          @validations = [] unless @validations
          @validations << block
        end
      end
    
    end
    
    def valid?
      self.class.validations.all?{|v| !!v.bind(self).call}
    end
    
  end
end
