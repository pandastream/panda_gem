module Panda
  class Profile < Resource
    include Panda::Updatable

    has_many :encodings

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