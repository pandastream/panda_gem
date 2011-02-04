module Panda
  module Finders

    def self.included(base)
      base.extend(FindOne)
      base.extend(FindMany)
    end
    
    module FindOne

      def find(id)
        raise 'find method requires a correct value' if id.nil? || id == ''
        find_by_path(one_path, {:id => id})
      end

      def find_object_by_path(url, map={})
        rest_url = create_rest_url(url, map)
        params = extract_unmapped_variables(url, map)
        connection.get(rest_url, params)
      end

      def find_by_path(url, map={})
        object = find_object_by_path(url, map)
        kclass = Panda::const_get("#{sti_name}")

        if object.is_a?(Array)
          object.map{|o| kclass.new(o)}
        elsif object['id']
          kclass.new(object)
        else
          raise APIError.new(object)
        end
      end

    end

    module FindMany

      def find_by(map)
        all(map).first
      end

      def all(map={})
        find_by_path(many_path, map)
      end

      private

      def find_all_by_has_many(relation_name, relation_value)
         map = {}
         map[relation_name.to_sym] = relation_value
         has_many_path = build_hash_many_path(many_path, relation_name)
         find_by_path(has_many_path, map)
      end

      def method_missing(method_symbol, *arguments)
        method_name = method_symbol.to_s
        if method_name =~ /^find_all_by_([_a-zA-Z]\w*)$/
          find_all_by_has_many($1, arguments.pop)
        else
          super
        end
      end

    end

  end
end