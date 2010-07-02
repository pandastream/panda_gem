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
      
      def format
        ".json"
      end
      
      def format_element_path(element_path)
        element_path + Base.format
      end
      
      def find(id)
        new(Panda.connection.get(format_element_path(path+"/"+id.to_s)))
      end
      
      def all
         Panda.connection.get(format_element_path(path)).map{|v| new(v)}
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