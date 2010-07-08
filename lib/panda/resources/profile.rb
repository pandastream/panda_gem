module Panda
  class Profile < Resource
    include Panda::Updatable
    has_many :encodings
  end
end