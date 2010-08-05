module Panda
  class ProfileScope < Scope
    def initialize(parent)
      super(parent, Profile)
    end
  end
end
