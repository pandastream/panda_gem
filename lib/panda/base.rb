module Panda
  class Base
    
    attr_accessor :attributes, :errors, :connection
    
    def initialize(attributes = {})
      @connection = Base.connection
      @attributes = {}
      load(attributes)
      @errors = []
    end
    
    include Panda::Router
    include Panda::Connectable
    include Panda::Validatable
    include Panda::Associations
    
    class << self
      
      def find(id)
        find_by_path(one_path, {:id => id})
      end

      def find_by(map)
        find_by_path(one_path, map)
      end

      def find_all_by(map)
        find_by_path(many_path, map)
      end
      
      def find_all_by_has_many(relation_name, relation_value)
         map = {}
         map[relation_name.to_sym] = relation_value
         has_many_path = build_hash_many_path(many_path, relation_name)
         find_by_path(has_many_path, map)
       end

      def all
        find_by_path(many_path)
      end
      
      def find_by_path(url, map={})
        full_url = element_url(url, map)
        params = element_params(url, map)
        
        object = self.connection.get(element_url(full_url, map), params)
        if object.is_a?(Array)
          object.map{|v| new(v.merge(map))}
        elsif object["id"]
          new(object.merge(map))
        else
          Error.new(object).raise!
        end
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
      response = connection.delete(element_url_map(self.class.one_path))
      response['deleted'] == 'ok'
    end
    
    def create
      return false if !valid?
      response = connection.post(element_url_map(self.class.many_path), @attributes)
      load_response(response)
      response['error'].nil? && !response['id'].nil?
    end
    
    def update
      return false if !valid?
      response = connection.put(element_url_map(self.class.one_path), @attributes)
      load_response(response)
      response['error'].nil? && !response['id'].nil?
    end
    
    def id
      attributes['id']
    end
    
    def id=(id)
      attributes['id'] = id
    end
    
    def reload
      record_id = id
      @errors = []
      attributes = {}
      self.load(self.class.find(record_id))
    end

    private

    def load(attributes)
      attributes.each do |key, value|
        @attributes[key.to_s] = value
      end
    end
    
    def load_response(response)
      if response['error']
        @errors << Error.new(response)
      else
        load(response)
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
        super
      end
    end
  
  end
end