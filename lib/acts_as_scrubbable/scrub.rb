module ActsAsScrubbable
  module Scrub

    def scrub!
      require 'faker'

      if self.class.scrubbable?
        _updates = {}
        scrubbable_fields.each do |key, value|
          next if self.send(key).blank?

          _updates[key] = if value == :first_name
                            Faker::Name.first_name
                          elsif value == :last_name
                            Faker::Name.last_name
                          elsif value == :full_name
                            Faker::Name.name
                          elsif value == :middle_name
                            Faker::Name.name
                          elsif value == :street_address
                            Faker::Address.street_address
                          elsif value == :secondary_address
                            Faker::Address.secondary_address
                          elsif value == :city
                            Faker::Address.city
                          elsif value == :latitude
                            Faker::Address.latitude
                          elsif value == :longitude
                            Faker::Address.longitude
                          elsif value == :email
                            Faker::Internet.email
                          elsif value == :name_title
                            Faker::Name.title
                          elsif value == :company_name
                            Faker::Company.name
                          else
                            nil
                          end
        end
        self.update_columns(_updates) unless _updates.empty?
      end
    end
  end
end
