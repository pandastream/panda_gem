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
      uri = replace_pattern_with_self_variables(self.class.one_path)
      response = connection.put(uri, @changed_attributes)
      load_and_reset(response)
    end

  end
end