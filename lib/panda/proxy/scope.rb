require 'forwardable'

module Panda
  class Scope < Proxy
    extend Forwardable
    
    def really_respond_to?(method)
      !([].methods - non_delegate_methods + ['reload']).include?(method.to_s)
    end

    def non_delegate_methods
      %w(nil? send object_id respond_to? class find find_by create create! all)
    end
    
    def initialize(parent, klass)
      @parent = parent
      @klass = klass

      initialize_scope_attributes
      initialize_scopes
    end

    # Overide the function to set the cloud_id as the same as the scope
    def find_by_path(url, map={})
      object = find_object_by_path(url, map)

      if object.is_a?(Array)
        object.map{|o| klass.new(o.merge("cloud_id" => cloud.id))}
      elsif object["id"]
        klass.new(object.merge("cloud_id" => cloud.id))
      else
        Error.new(object).raise!
      end        
    end

    def create(attributes)
      scoped_attrs = attributes.merge(@scoped_attributes)
      super(scoped_attrs)
    end

    def all(attributes={})
      @scoped_attributes.merge!(attributes)
      trigger_request
    end
    
    def cloud
      @parent.is_a?(Cloud) ? @parent : @parent.cloud
    end
    
    def connection
      cloud.connection
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
        [].methods.each do |m|
          unless m =~ /^__/ || non_delegate_methods.include?(m.to_s)
            self.class.class_eval do
              def_delegators :proxy_found, m
            end
          end
        end
      end

      def trigger_request
        if @parent.is_a?(Resource)
          has_many_path = build_hash_many_path(many_path, parent_relation_name)
          klass.find_by_path(has_many_path, @scoped_attributes)
        else
          klass.all(@scoped_attributes)
        end
      end

      def parent_relation_name
        "#{@parent.class.end_class_name.downcase}_id"
      end
      
  end
end
