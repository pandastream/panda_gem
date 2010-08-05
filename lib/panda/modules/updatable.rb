module Panda
  module Updatable

    def save
      new? ? create : update
    end

    def save!
      save || raise("Resource invalid")
    end

    def update_attribute(name, value)
      self.send("#{name}=".to_sym, value)
      self.save
    end

    def update_attributes(attributes)
      load(attributes) && save
    end

    def update
      response = connection.put(object_url_map(self.class.one_path), @changed_attributes)
      load_response(response) ? (@changed_attributes = {}; true) : false
    end

  end
end