module Panda
  module Finders
    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(PathFinder)
    end
    
    module ClassMethods
      
      def find(id)
        find_by_path(one_path, {:id => id})
      end

      def find_by(map)
        find_by_path(many_path, map).first
      end

      def all(map )
        find_by_path(many_path, map)
      end

      private

      def find_all_by_has_many(relation_name, relation_value)
         map = {}
         map[relation_name.to_sym] = relation_value
         has_many_path = build_hash_many_path(many_path, relation_name)
         find_by_path(has_many_path, map)
      end
      
    end
    
    module PathFinder
      def find_by_path(url, map={})
        object = find_object_by_path(url, map)
        if object.is_a?(Array)
          object.map{|v| new(v.merge(map))}
        elsif object["id"]
          new(object.merge(map))
        else
          Error.new(object).raise!
        end
      end
    end
    
  end
end