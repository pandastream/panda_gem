module Panda
  class Profile < Resource
    include Panda::Updatable

    def encodings
      @encodings ||= EncodingScope.new(self)
    end

    class << self
      def method_missing(method_symbol, *args, &block)
        if respond_to?(method_symbol)
           Scope.new(Profile,self).send(method_symbol, *args, &block)
        else
          super
        end
      end

      def respond_to?(method)
        super || Scope.new(Profile,self).respond_to?(method)
      end
    end

    def reload
      @encodings = nil
      super
    end

    def preset?
      !preset_name
    end

    # override attributes command and preset_name
    # to ovoid <method undefined> when profile is a preset or not
    def command
      @attributes['command']
    end

    def preset_name
      @attributes['preset_name']
    end

  end
end