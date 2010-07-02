module Panda
  class Base
    
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
        raise "No rest path"
      end
      
      def index_path
        path + Base.format
      end
      
      def show_path
         path + "/:id" + Base.format
      end
 
      def format
        ".json"
      end
      
      def format_element_path(url, map)
        url.gsub(/:(\w)+/) { |key| map[key[1..-1].to_sym] || map[key[1..-1].to_s] }
      end
      
      def find(id)
        find_by_path(show_path, {:id => id})
      end      

      def all
         find_by_path(index_path)
      end
      
      def find_by_path(map={}, suffix="")
        object = Panda.connection.get(format_element_path(map, suffix))
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
      Panda.connection.post(format_element_path(path))
    end
    
    def update
      Panda.connection.put(format_element_path(path))
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