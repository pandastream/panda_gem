module Panda
  class VideoScope < Scope

    def initialize(parent)
      super(parent, Video)
    end

    def non_delegate_methods
      super + [:status, :page, :per_page]
    end

    def page(this_page)
      @scoped_attributes[:page] = this_page
      self
    end

    def per_page(this_per_page)
      @scoped_attributes[:per_page] = this_per_page
      self
    end

    def status(this_status)
      @scoped_attributes[:status] = this_status
      self
    end

  end
end