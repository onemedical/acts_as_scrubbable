module ActsAsScrubbable
  module Scrub
    def scrub!
      return unless self.class.scrubbable?

      run_callbacks(:scrub) do
        if self.class.sterilizable?
          self.destroy!
          next
        end

        _updates = {}

        scrubbable_fields.each do |_field, value|
          unless self.respond_to?(_field)
            raise ArgumentError, "#{self.class} do not respond to #{_field}"
          end
          next if self.send(_field).blank? || value == :skip

          if ActsAsScrubbable.scrub_map.keys.include?(value)
            _updates[_field] = ActsAsScrubbable.scrub_map[value].call
          elsif value == :wipe
            _updates[_field] = nil
          else
            puts "Undefined scrub: #{value} for #{self.class}.#{_field}"
          end
        end

        self.update_columns(_updates) unless _updates.empty?
      end
    end
  end
end
