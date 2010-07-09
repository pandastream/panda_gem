module Panda
  class Scope < Proxy


    NON_DELEGATE_METHODS=%w(nil? send object_id respond_to? class find find_by all create create!)

    def initialize(target, kclass, cloud)
      @target = target
      @kclass = kclass
      @cloud = cloud

      initialize_scopes
    end

    def find_by_path(url, map={})
      object = find_object_by_path(url, map)
      kclass = Panda::const_get("#{name.split('::').last}")

      if object.is_a?(Array)
        object.map{|o| r=kclass.new(o); r.cloud = @cloud; r}
      elsif object["id"]
        r=kclass.new(object);r.cloud=@cloud;r
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
        if @target
          Panda::const_get(kclass)[send(:cloud)].
            send("find_all_by_#{target_relation_name}", @target.id)
        else
          Panda::const_get(kclass)[send(:cloud)].all
        end
      end

      def target_relation_name
        "#{@target.class.name.split('::').last.downcase}_id"
      end
      
      def merge_with_target(attributes)
        scoped_attrs = attributes.clone
        if @target
          scoped_attrs[target_relation_name.to_sym] = @target.id
        end
        scoped_attrs
      end
  end
end
