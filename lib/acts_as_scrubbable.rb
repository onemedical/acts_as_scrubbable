require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'
require 'acts_as_scrubbable/tasks'


module ActsAsScrubbable
  extend ActiveSupport::Autoload

  autoload :Scrubbable
  autoload :Scrub
  autoload :VERSION

  def self.configure(&block)
    yield self
  end

  def self.add(key, value)
    ActsAsScrubbable.scrub_map[key] = value
  end

  def self.scrub_map
    require 'faker'

    @_scrub_map ||= {
      :first_name        => -> { Faker::Name.first_name },
      :last_name         => -> { Faker::Name.first_name },
      :middle_name       => -> { Faker::Name.name },
      :full_name         => -> { Faker::Name.name },
      :email             => -> { Faker::Internet.email },
      :name_title        => -> { Faker::Name.title },
      :company_name      => -> { Faker::Company.name },
      :street_address    => -> { Faker::Address.street_address },
      :secondary_address => -> { Faker::Address.secondary_address },
      :city              => -> { Faker::Address.city },
      :latitude          => -> { Faker::Address.latitude },
      :longitude         => -> { Faker::Address.longitude }
    }
  end
end


ActiveSupport.on_load(:active_record) do
  extend ActsAsScrubbable::Scrubbable
end
