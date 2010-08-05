module Panda
  class EncodingScope < Scope

    def initialize(parent)
      super(parent, Encoding)
    end

    def non_delegate_methods
      super + [:status, :profile_id, :profile_name, :video, :page, :per_page]
    end

    def page(this_page)
      @scoped_attributes[:page] = this_page
      self
    end

    def per_page(this_per_page)
      @scoped_attributes[:per_page] = this_per_page
      self
    end

    def video(this_video_id)
      @scoped_attributes[:video_id] = this_video_id
      self
    end

    def status(this_status)
      @scoped_attributes[:status] = this_status
      self
    end

    def profile(this_profile_id)
      @scoped_attributes[:profile_id] = this_profile_id
      self
    end

    def profile_name(this_profile_name)
      @scoped_attributes[:profile_name] = this_profile_name 
      self
    end

    def find_by_profile_name(this_profile_name)
      @scoped_attributes[:profile_name] = this_profile_name
      trigger_request.first
    end

  end
end