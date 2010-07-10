module Panda
  class Profile < Resource
    include Panda::Updatable

    def encodings
      @encodings ||= EncodingScope.new(self)
    end

  end
end