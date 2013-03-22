module Panda
  module Associations
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def has_one(relation_name)
        define_method relation_name do
          param_id = "#{relation_name}_id"
          if instance_var = instance_variable_get("@#{relation_name}")
            instance_var
          else
            @associations ||= []
            @associations << relation_name
            instance_variable_set("@#{relation_name}",
              self.cloud.send("#{relation_name}s").find(send(param_id.to_sym)))
          end
        end
      end

      def has_many(relation_name)
        define_method relation_name do
          model_name = "#{relation_name.to_s[0..-2].capitalize}"
          if instance_var = instance_variable_get("@#{relation_name}")
            instance_var
          else
            @associations ||= []
            @associations << relation_name
            instance_variable_set("@#{relation_name}",
              Panda::const_get("#{model_name}Scope").new(self))
          end
        end
      end

      alias :belongs_to :has_one

    end

    private
    def reset_associations
      if @associations
        @associations.each do |a|
          instance_variable_set("@#{a}",nil)
        end
      end
    end

  end
end
