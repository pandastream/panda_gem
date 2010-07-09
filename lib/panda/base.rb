module Panda
  class Base    
    attr_accessor :attributes, :errors
    include Panda::Router
    
    def initialize(attributes = {})
      @attributes = {}
      @changed_attributes = {}
      @errors = []
      load(attributes)
    end
    
    def new?
      id.nil?
    end
    
    def delete
      response = connection.delete(object_url_map(self.class.one_path))
      response['deleted'] == 'ok'
    end
    
    def id
      attributes['id']
    end
    
    def id=(id)
      attributes['id'] = id
    end
        
    def to_json
      attributes.to_json
    end
    
    private

    def load(attributes)
      attributes.each do |key, value|
        @attributes[key.to_s] = value
        @changed_attributes[key.to_s] = value if !(attributes['id'] || attributes[:id])
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
          @changed_attributes[$`] = arguments.first
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