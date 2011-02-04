module Panda
  module Router
    VAR_PATTERN = /:\w+/

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def resource_path
        @url || "/#{sti_name.downcase}s"
      end

      def match(url)
        @url = url
      end

      def many_path
        resource_path
      end

      def one_path
        resource_path + "/:id"
      end

      def build_hash_many_path(end_path, relation_attr)
        relation_class_name = relation_attr[0..relation_attr.rindex("_id")-1].capitalize
        prefix_path = Panda::const_get(relation_class_name).resource_path + "/:" + relation_attr
        prefix_path + end_path
      end

      def create_rest_url(url, map)
        new_url = replace_pattern_with_variables(url, map)
        json_path(new_url)
      end
      
      private

      def replace_pattern_with_variables(url, map)
        new_url = url.clone
        new_url.gsub(VAR_PATTERN){|key| map[key[1..-1].to_sym] || map[key[1..-1].to_s]}
      end
      
      def extract_unmapped_variables(url, map)
        params = map.clone
        url.scan(VAR_PATTERN).map{|key| params.reject!{|k,v| k==key[1..-1] } }
        params
      end

      def json_path(uri)
        uri + ".json"
      end
    end

    def replace_pattern_with_self_variables(url)
      self.class.create_rest_url(url, attributes)
    end

  end
end
