module Panda
  class Scope < Proxy

    include Panda::Finders::ClassMethods
    include Panda::Finders::PathFinder
    include Panda::Builders::CreateBuilder

    NON_DELEGATE_METHODS=%w(nil? send object_id find create all size respond_to? inspect class)

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
            send("find_all_by_#{@target.class.name.split('::').last.downcase}_id", @target.id)
        else
          Panda::const_get(kclass)[send(:cloud)].all
        end
      end

  end
end
