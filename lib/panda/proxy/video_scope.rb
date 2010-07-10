module Panda
  class VideoScope < Scope
    
    def initialize(parent)
      super(parent, Video)
    end
    
    def non_delegate_methods
      super + ['status']
    end
    
    def status(this_status)
      @scoped_attributes[:status] = this_status
      self
    end
    
  end
end