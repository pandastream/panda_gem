module Panda
  module Router
    DEFAULT_FORMAT = "json"
    VAR_PATTERN = /:\w+/
    
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def resource_url
        @url || "/#{self.name.split('::').last.downcase}s"
      end

      def resource_url=(url)
        @url = url
      end

      def match(url)
        self.resource_url = url
      end

      def many_path
        resource_url
      end

      def one_path
        resource_url + "/:id"
      end

      def build_hash_many_path(end_path, relation_attr)
        relation_class_name = relation_attr[0..relation_attr.rindex("_id")-1].capitalize
        prefix_path = Panda::const_get(relation_class_name).resource_url + "/:" + relation_attr
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

      def clone!
        new_self = self.clone
        new_self.resource_url = self.resource_url
        new_self.connection = self.connection
        new_self
      end
      
      def find_object_by_path(url, map={})
        full_url = object_url(url, map)
        params = element_params(url, map)
        connection.get(full_url, params)
      end
      
    end

    def object_url_map(url)
      self.class.full_object_url(url.clone.gsub(VAR_PATTERN) {|key| send(key[1..-1].to_sym)})
    end
    
  end
end
