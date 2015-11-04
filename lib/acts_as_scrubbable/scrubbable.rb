module ActsAsScrubbable
  module Scrubbable


    def scrubbable?
      false
    end


    def acts_as_scrubbable(*scrubbable_fields)

      class_attribute :scrubbable_fields

      self.scrubbable_fields = {}

      scrubbable_fields.each do |_field|
        if _field.is_a? Hash
          self.scrubbable_fields[_field.keys.first] = _field.values.first
        else
          self.scrubbable_fields[_field] = _field
        end
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
