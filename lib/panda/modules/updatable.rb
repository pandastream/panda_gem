module Panda
  module Updatable

    def save
      new? ? create : update
    end

    def save!
      save || raise(errors.last)
    end

    def update_attribute(name, value)
      send("#{name}=".to_sym, value) && save
    end

    def update_attributes(attributes)
      load(attributes) && save
    end

    def update_attributes!(attributes)
      update_attributes(attributes) || raise(errors.last)
    end

    def update
      uri = replace_pattern_with_self_variables(self.class.one_path)
      response = connection.put(uri, @changed_attributes)
      load_and_reset(response)
    end

  end
end