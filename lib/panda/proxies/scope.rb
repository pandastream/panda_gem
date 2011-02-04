require 'forwardable'

module Panda
  class Scope < Proxy
    extend Forwardable

    def respond_to?(method)
      scoped_methods = [].methods.map{|i| i.to_sym} - non_delegate_methods + [:reload, :non_delegate_methods]
      !(scoped_methods).include?(method.to_sym)
    end

    def non_delegate_methods
       [:nil?, :send, :object_id, :respond_to?, :class, :find, :find_by, :create, :create!, :all, :cloud, :connection]
    end

    def initialize(parent, klass)
      super

      initialize_scope_attributes
      initialize_scopes
    end
    
    # Overide the function to set the cloud_id as the same as the scope
    def find_by_path(url, map={})
      object = find_object_by_path(url, map)

      if object.is_a?(Array)
        object.map{|o| klass.new(o.merge('cloud_id' => cloud.id))}
      elsif object['id']
        klass.new(object.merge('cloud_id' => cloud.id))
      else
        raise APIError.new(object)
      end
    end

    def create(attributes)
      scoped_attrs = attributes.merge(@scoped_attributes)
      super(scoped_attrs)
    end

    def create!(attributes)
      scoped_attrs = attributes.merge(@scoped_attributes)
      super(scoped_attrs)
    end

    def all(attributes={})
      @scoped_attributes.merge!(attributes)
      trigger_request
    end

    def reload
      @found = trigger_request
    end
    
    private

    def initialize_scope_attributes
      @scoped_attributes={}
      if @parent.is_a?(Panda::Resource)
        @scoped_attributes[parent_relation_name.to_sym] = @parent.id
      end
    end

    def proxy_found
      @found ||= trigger_request
    end

    def initialize_scopes
      ([].methods + [:to_json]).each do |m|
        unless m.to_s =~ /^__/ || non_delegate_methods.include?(m.to_sym)
          self.class.class_eval do
            def_delegators :proxy_found, m.to_sym
          end
        end
      end
    end

    def trigger_request
      if @parent.is_a?(Resource)
        path = build_hash_many_path(many_path, parent_relation_name)
      else
        path = many_path
      end

      find_by_path(path, @scoped_attributes)
    end

    def parent_relation_name
      "#{@parent.class.sti_name.downcase}_id"
    end
    
  end
end
