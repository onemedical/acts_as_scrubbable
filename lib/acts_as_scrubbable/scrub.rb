module ActsAsScrubbable
  module Scrub

    def scrub!
      return unless self.class.scrubbable?

      run_callbacks(:scrub) do
        _updates = {}

        scrubbable_fields.each do |_field, value|
          unless self.respond_to?(_field)
            raise ArgumentError, "#{self.class} do not respond to #{_field}"
          end
          next if self.send(_field).blank?

          if ActsAsScrubbable.scrub_map.keys.include?(value)
            _updates[_field] = ActsAsScrubbable.scrub_map[value].call
          else
            puts "Undefined scrub: #{value} for #{self.class}#{_field}"
           end
        end

        _updates
      end
    end
  end
end
