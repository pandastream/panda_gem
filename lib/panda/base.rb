module Panda
  class Base
    
    DEFAULT_FORMAT = "json"
    
    attr_accessor :attributes
    
    def connection 
      Panda.connection
    end
    
    def cloud_id
      connection.cloud_id
    end
    
    def initialize(attributes = {})
      @attributes = {}
      load(attributes)
    end
        
    class << self
      def resource_url
        @url || "/#{self.name.split('::').last.downcase}s"
      end

      def resource_url=(url)
        @url = url
      end
      
      def match(url)
        self.resource_url = url
      end
      
      def has_many(*property_names)
        property_names.collect do |name|
          define_method name do
            param_id = "#{self.class.name[0..-1].split('::').last.downcase}_id"
            unless instance_variable_get("@#{name.to_s}")
              instance_variable_set("@#{name.to_s}",
               Panda::const_get(name.to_s[0..-2].capitalize).send("find_all_by_#{param_id}",send(:id)))
            end
          end
        end
      end
      
            
      def has_one(*property_names)
        property_names.collect do |name|
          define_method name do
            param_id = "#{name.to_s}_id"
            unless instance_variable_get("@#{name.to_s}")
              instance_variable_set("@#{name.to_s}", 
                Panda::const_get(name.to_s.capitalize).find(send(param_id.to_sym)))
            end
          end
        end
      end
      alias :belongs_to :has_one
      
      def get_all_path
        resource_url + ".#{DEFAULT_FORMAT}"
      end
      
      def get_one_path
         resource_url + "/:id.#{DEFAULT_FORMAT}"
      end
 
      def element_url(url, map)
        url.clone.gsub(/:(\w)+/) { |key| map[key[1..-1].to_sym] || map[key[1..-1].to_s]}
      end
      
      def find(id)
        find_by_path(get_one_path, {:id => id})
      end      

      def all
         find_by_path(get_all_path)
      end
      
      def find_by_path(map={}, suffix="")
        object = Panda.connection.get(element_url(map, suffix))
        if object.is_a?(Array)
          object.map{|v| new(v)}
        else
          new(object)
        end
      end

      
      def method_missing(method_symbol, *arguments)
        method_name = method_symbol.to_s
        if method_name =~ /^find_(all_by|by)_([_a-zA-Z]\w*)$/
          finder = $1
          names = $2
          if finder == "all_by"
            map = {}
            map[$2.to_sym] = arguments.pop
            find_by_path(get_all_path, map)
          end
        else
          super
        end
      end

    end
    
    def new?
      id.nil?
    end
    
    def save
      new? ? create : update
    end
    
    def save!
      save || raise("Resource invalid")
    end
    
    def update_attribute(name, value)
      self.send("#{name}=".to_sym, value)
      self.save
    end

    def update_attributes(attributes)
      load(attributes) && save
    end
    
    def delete
      connection.delete(element_path + "/" + id.to_s + ".json")
    end
    
    def create
      Panda.connection.post(element_url(path))
    end
    
    def update
      Panda.connection.put(element_url(path))
    end
    
    private

      
    def load(attributes)
      attributes.each do |key, value|
        @attributes[key.to_s] = value
      end
    end
    
    def id
      attributes['id']
    end
    
    def id=(id)
      attributes['id'] = id
    end
    
    def reload
      self.load(self.class.find())
    end
    
    match "/#{self.name.split('::').last.downcase}s"
    
    def method_missing(method_symbol, *arguments)
      method_name = method_symbol.to_s
      if method_name =~ /(=|\?)$/
        case $1
        when "="
          attributes[$`] = arguments.first
        when "?"
          attributes[$`]
        end
      else
        return attributes[method_name] if attributes.include?(method_name)
        super
      end
    end
  
  end
end