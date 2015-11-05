module ActsAsScrubbable
  module Scrub

    def scrub!
      if self.class.scrubbable?
        _updates = {}

        scrubbable_fields.each do |key, value|
          next if self.send(key).blank?

          _updates[key] = ActsAsScrubbable.scrub_map[value].call
        end

        self.update_columns(_updates) unless _updates.empty?
      end

    end
  end
end
