module Panda
  class Scope < Proxy
    NON_DELEGATE_METHODS=%w(nil? send object_id respond_to? class find find_by create create! all)

    def initialize(parent, klass)
      @parent = parent
      @klass = klass
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
      scoped_attrs = merge_with_parent(attributes)
      super(scoped_attrs)
    end

    def all(attributes={})
      if @parent.is_a?(Resource)
        scoped_attrs = merge_with_parent(attributes)
        has_many_path = build_hash_many_path(many_path, parent_relation_name)
        klass.find_by_path(has_many_path, scoped_attrs)
      else
        super(attributes)
      end
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
          klass.send("find_all_by_#{parent_relation_name}", @parent.id)
        else
          klass.all
        end
      end

      def parent_relation_name
        "#{@parent.class.name.split('::').last.downcase}_id"
      end
      
      def merge_with_parent(attributes)
        scoped_attrs = attributes.clone
        if @parent.is_a?(Panda::Resource)
          scoped_attrs[parent_relation_name.to_sym] = @parent.id
        end
        scoped_attrs
      end
  end
end
