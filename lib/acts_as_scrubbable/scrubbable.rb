module ActsAsScrubbable
  module Scrubbable


    def scrubbable?
      false
    end


    def acts_as_scrubbable(*scrubbable_fields, **mapped_fields)

      class_attribute :scrubbable_fields

      self.scrubbable_fields = {}
      scrubbable_fields.each do |_field|
        self.scrubbable_fields[_field] = _field
      end

      mapped_fields.each do |_field|
        self.scrubbable_fields[_field.first] = _field.last
      end

      class_eval do

        def self.scrubbable?
          true
        end

      end

      include Scrub
    end

  end
end
