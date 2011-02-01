module Panda
  class Resource < Base
    include Panda::Destroyers
    include Panda::Associations
    include Panda::CloudConnection

    def initialize(attributes={})
      super(attributes)
      @attributes['cloud_id'] ||= Panda.cloud.id
    end

    class << self
      include Panda::CloudConnection

      def cloud
        Panda.cloud
      end

      # delegate to the scope if the method exists
      def method_missing(method_symbol, *args, &block)
        scope = Panda::const_get("#{sti_name}Scope").new(self)
        if scope.respond_to?(method_symbol)
           scope.send(method_symbol, *args, &block)
        else
          super
        end
      end

    end

    def cloud
      Panda.clouds[cloud_id]
    end

    def reload
      perform_reload("cloud_id" => cloud_id)
      reset_associations
      self
    end

  end
end
