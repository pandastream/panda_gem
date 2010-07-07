module Panda
  class Base
    
    attr_accessor :attributes, :errors, :connection
    
    def initialize(attributes = {})
      @connection = self.class.connection
      @attributes = {}
      load(attributes)
      @errors = []
    end
    
    include Panda::Router
    include Panda::Connectable
    include Panda::Associations
    
    class << self
  
      private
      
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
      response = connection.delete(object_url_map(self.class.one_path))
      response['deleted'] == 'ok'
    end
    
    def create
      response = connection.post(object_url_map(self.class.many_path), @attributes)
      load_response(response)
    end
    
    def create!
      create || errors.last.raise!
    end
    
    def update
      response = connection.put(object_url_map(self.class.one_path), @attributes)
      load_response(response)
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
        @errors=[]
        load(response)
      end
      
      response['error'].nil? && !response['id'].nil?
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