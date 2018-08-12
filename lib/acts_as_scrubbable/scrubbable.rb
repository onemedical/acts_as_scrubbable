module ActsAsScrubbable
  module Scrubbable
    def scrubbable?
      false
    end

    def acts_as_scrubbable(scrub_type=:scrub, *scrubbable_fields, **mapped_fields)
      unless self.respond_to?(:scrubbable_fields)
        class_attribute :scrubbable_fields
        self.scrubbable_fields = {}
      end

      unless self.respond_to?(:sterilizable?)
        class_attribute :sterilizable
        self.sterilizable = scrub_type == :sterilize
      end

      scrubbable_fields.each do |field_name|
        self.scrubbable_fields[field_name] = scrub_type == :scrub ? field_name : scrub_type
      end

      mapped_fields.each { |field_name, field_type| self.scrubbable_fields[field_name] = field_type }

      class_eval do
        define_callbacks :scrub

        def self.scrubbable?
          true
        end
      end

      include Scrub
    end
  end
end
