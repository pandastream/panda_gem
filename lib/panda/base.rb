require 'forwardable'

module Panda
  class Base
    attr_accessor :attributes, :errors
    extend Forwardable
    
    include Panda::Router
    include Panda::Builders
    include Panda::Finders

    def_delegators :attributes, :to_json

    def initialize(attributes = {})
      clear_attributes
      load(attributes)
    end

    class << self
      def sti_name
        "#{name.split('::').last}"
      end
    end

    def changed?
      !@changed_attributes.empty?
    end

    def new?
      id.nil?
    end

    def id
      attributes['id']
    end

    def id=(id)
      attributes['id'] = id
    end

    def reload
      perform_reload
      self
    end

    private

    def load_and_reset(response)
      load_response(response)
    end
    
    def perform_reload(args={})
      raise "RecordNotFound" if new?

      url = self.class.create_rest_url(self.class.one_path, :id => id)
      response = connection.get(url)
      load_response(response.merge(args))
    end

    def clear_attributes
      @attributes = {}
      @changed_attributes = {}
      @errors = []
    end

    def load(attributes)
      not_a_response = !(attributes['id'] || attributes[:id])
      attributes.each do |key, value|
        @attributes[key.to_s] = value
        @changed_attributes[key.to_s] = value if not_a_response
      end
      true
    end

    def load_response(response)
      if response['error'] || response['id'].nil?
        @errors << APIError.new(response)
        @loaded = false
      else
        clear_attributes
        load(response)
        @changed_attributes = {};
        @loaded = true
      end
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