module Panda
  class Scope < Proxy

    def non_delegate_methods
      %w(nil? send object_id respond_to? class find find_by create create! all)
    end
    
    def initialize(parent, klass)
      @parent = parent
      @klass = klass

      initialize_scope_attributes
      initialize_scopes
    end

    def find_by_path(url, map={})
      object = find_object_by_path(url, map)

      if object.is_a?(Array)
        object.map{|o| r=klass.new(o); r.cloud_id = cloud.id; r}
      elsif object["id"]
        r=klass.new(object); r.cloud_id=cloud.id; r
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
    
    private

      def initialize_scope_attributes
        @scoped_attributes={}
        if @parent.is_a?(Panda::Resource)
          @scoped_attributes[parent_relation_name.to_sym] = @parent.id
        end
      end
      
      def initialize_scopes
        [].methods.each do |m|
          unless m =~ /^__/ || non_delegate_methods.include?(m.to_s)
            self.class.class_eval do
              define_method m do
                trigger_request.send(m)
              end
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
        "#{@parent.class.name.split('::').last.downcase}_id"
      end
      
  end
end
