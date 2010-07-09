module Panda
  class Scope < Proxy
    NON_DELEGATE_METHODS=%w(nil? send object_id respond_to? class find find_by all create create!)

    def initialize(target, klass)
      @parent = target
      @klass = klass
      initialize_scopes
    end

    def find_by_path(url, map={})
      object = find_object_by_path(url, map)

      if object.is_a?(Array)
        object.map{|o| r=klass.new(o); r.cloud_id = cloud.id; r}
      elsif object["id"]
        r=klass.new(object);r.cloud_id=cloud.id;r
      else
        Error.new(object).raise!
      end        
    end

    def create(attributes)
      scoped_attrs = merge_with_target(attributes)
      super(scoped_attrs)
    end

    def all(attributes={})
      scoped_attrs = merge_with_target(attributes)
      super(scoped_attrs)
    end
    
    def cloud
      @parent.is_a?(Cloud) ? @parent : @parent.cloud
    end
    
    def connection
      cloud.connection
    end
    
    private

      def initialize_scopes
        [].methods.each do |m|
          unless m =~ /^__/ || NON_DELEGATE_METHODS.include?(m.to_s)
            self.class.class_eval do
              define_method m do
                trigger_request.send(m)
              end
            end
          end
        end
      end

      def trigger_request
        if @parent.is_a?(Panda::Resource)
          klass.send("find_all_by_#{target_relation_name}", @parent.id)
        else
          klass.all
        end
      end

      def target_relation_name
        "#{@parent.class.name.split('::').last.downcase}_id"
      end
      
      def merge_with_target(attributes)
        scoped_attrs = attributes.clone
        if @parent.is_a?(Panda::Resource)
          scoped_attrs[target_relation_name.to_sym] = @parent.id
        end
        scoped_attrs
      end
  end
end
