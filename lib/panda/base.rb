module Panda
  class Base
    
    DEFAULT_FORMAT = "json"
    
    attr_accessor :attributes
    
    def connection 
      Panda.connection
    end
    
    def initialize(attributes = {})
      @attributes = {}
      load(attributes)
    end
    
    class << self
      
      def path
        "/#{self.name.split('::').last.downcase}s"
      end
      
      def get_one_path
        path + ".#{DEFAULT_FORMAT}"
      end
      
      def get_all_path
         path + "/:id.#{DEFAULT_FORMAT}"
      end
 
      def element_url(url, map)
        url.gsub(/:(\w)+/) { |key| map[key[1..-1].to_sym] || map[key[1..-1].to_s]}
      end
      
      def find(id)
        find_by_path(get_all_path, {:id => id})
      end      

      def all
         find_by_path(get_one_path)
      end
      
      def find_by_path(map={}, suffix="")
        object = Panda.connection.get(element_url(map, suffix))
        if object.is_a?(Array)
          object.map{|v| new(v)}
        else
          new(object)
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