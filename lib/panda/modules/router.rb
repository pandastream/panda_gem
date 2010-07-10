module Panda
  module Router
    DEFAULT_FORMAT = "json"
    VAR_PATTERN = /:\w+/
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def resource_path
        @url || "/#{end_class_name.downcase}s"
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
      
      def object_url(url, map)
        full_object_url(url.clone.gsub(VAR_PATTERN){|key| map[key[1..-1].to_sym] || map[key[1..-1].to_s]})
      end
      
      def element_params(url, map)
        params = map.clone
        url.clone.scan(VAR_PATTERN).map{|key| params.reject!{|k,v| k==key[1..-1] } }
        params
      end

      def full_object_url(url)
        url + ".#{DEFAULT_FORMAT}"
      end
      
    end

    def object_url_map(url)
      self.class.full_object_url(url.clone.gsub(VAR_PATTERN) {|key| send(key[1..-1].to_sym)})
    end
    
  end
end
