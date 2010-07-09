module Panda
  module Associations
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def has_many(relation_name)
        define_method relation_name do
          unless instance_variable_get("@#{relation_name}")
            klass = Panda::const_get(relation_name.to_s[0..-2].capitalize)
            instance_variable_set("@#{relation_name}", Scope.new(self, klass))
          end
        end
      end

      def has_one(relation_name)
        define_method relation_name do
          param_id = "#{relation_name}_id"
          unless instance_variable_get("@#{relation_name}")
            instance_variable_set("@#{relation_name}",
              Panda::const_get(relation_name.to_s.capitalize).find(send(param_id.to_sym)))
          end
        end
      end

      alias :belongs_to :has_one

    end
  end
end
