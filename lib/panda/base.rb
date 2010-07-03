class Proc
  def bind(other)
    return Proc.new do
        other.instance_eval(&self)
    end
  end
end

module Panda
  class Base
    
    DEFAULT_FORMAT = "json"
    
    attr_accessor :attributes, :connection
    
    def initialize(attributes = {})
      @connection = Base.connection
      @attributes = {}
      load(attributes)
    end
    
    def cloud_id
      connection.cloud_id
    end

    class << self
    
      def connection 
        @connection ||= Panda.connection
      end      
    
      def connection=(c)
        @connection = c
      end
      
      def validations
        @validations.to_a
      end
      
      def [](connection)
        new_clone = self.clone!
        new_clone.connection = connection
        new_clone
      end
      
      def resource_url
        @url || "/#{self.name.split('::').last.downcase}s"
      end

      def resource_url=(url)
        @url = url
      end
      
      def match(url)
        self.resource_url = url
      end
      
      def validate(&block)
        def initialize
          
        end
        
        if block_given?
          @validations = [] unless @validations
          @validations << block
        end
      end
      
      
      def has_many(*property_names)
        property_names.collect do |name|
          define_method name do
            param_id = "#{self.class.name[0..-1].split('::').last.downcase}_id"
            unless instance_variable_get("@#{name.to_s}")
              instance_variable_set("@#{name.to_s}",
               Panda::const_get(name.to_s[0..-2].capitalize)[send(:connection)].send("find_all_by_#{param_id}",send(:id)))
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
                Panda::const_get(name.to_s.capitalize)[send(:connection)].find(send(param_id.to_sym)))
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
      
      def find_by_path(url, map={})
        object = self.connection.get(element_url(url, map))
        if object.is_a?(Array)
          object.map{|v| new(v.merge(map))}
        else
          new(object.merge(map))
        end
      end

      def clone!
        new_self = self.clone
        new_self.resource_url = self.resource_url
        new_self.connection = self.connection
        new_self
      end

      def method_missing(method_symbol, *arguments)
        method_name = method_symbol.to_s
        map = {}
        
        if method_name =~ /^find_(all_by|by)_([_a-zA-Z]\w*)$/
          finder = $1; names = $2
          if finder == "all_by"
            map[$2.to_sym] = arguments.pop
            find_by_path(get_all_path, map)
          end
        else
          super
        end
      end
    end
    
    def valid?
      self.class.validations.all?{|v| !!v.bind(self).call}
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
      response = connection.delete(element_url_map(self.class.get_one_path))
      response['deleted'] == 'ok'
    end
    
    def create
      return false if !valid?
      response = connection.post(element_url_map(self.class.get_all_path), @attributes)
      load(response)
      response['error'].nil? && !response['id'].nil?
    end
    
    def update
      return false if !valid?
      response = connection.put(element_url_map(self.class.get_one_path), @attributes)
      load(response)
      response['error'].nil? && !response['id'].nil?
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

    private
    
    def element_url_map(url)
      url.clone.gsub(/:(\w)+/) { |key| @attributes[key[1..-1].to_sym] || @attributes[key[1..-1].to_s]}
    end
    
    def load(attributes)
      attributes.each do |key, value|
        @attributes[key.to_s] = value
      end
    end
    
    def method_missing(method_symbol, *arguments)
      method_name = method_symbol.to_s
      if method_name =~ /(=|\?)$/
        case $1
        when '='
          attributes[$`] = arguments.first
        when '?'
          !! attributes[$`]
        end
      else
        return attributes[method_name] if attributes.include?(method_name)
        nil
      end
    end
  
  end
end