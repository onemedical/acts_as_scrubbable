require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'
require 'acts_as_scrubbable/tasks'
require 'term/ansicolor'
require 'logger'

module ActsAsScrubbable
  extend ActiveSupport::Autoload
  include Term::ANSIColor

  autoload :Scrubbable
  autoload :Scrub
  autoload :VERSION

  def self.configure(&block)
    yield self
  end

  def self.after_hook(&block)
    @after_hook = block
  end

  def self.execute_after_hook
    @after_hook.call if @after_hook
  end

  def self.logger
    @logger ||= begin
                  loggger = Logger.new($stdout)
                  loggger.formatter = proc do |severity, datetime, progname, msg|
                    "#{datetime}: [#{severity}] - #{msg}\n"
                  end
                  loggger
                end
  end

  def self.add(key, value)
    ActsAsScrubbable.scrub_map[key] = value
  end

  def self.scrub_map
    require 'faker'

    @_scrub_map ||= {
      :first_name => -> { Faker::Name.first_name },
      :last_name => -> { Faker::Name.last_name },
      :middle_name => -> { Faker::Name.name },
      :name => -> { Faker::Name.name },
      :email => -> { Faker::Internet.email },
      :name_title => -> { defined? Faker::Job ? Faker::Job.title : Faker::Name.title },
      :company_name => -> { Faker::Company.name },
      :street_address => -> { Faker::Address.street_address },
      :secondary_address => -> { Faker::Address.secondary_address },
      :zip_code => -> { Faker::Address.zip_code },
      :state_abbr => -> { Faker::Address.state_abbr },
      :state => -> { Faker::Address.state },
      :city => -> { Faker::Address.city },
      :latitude => -> { Faker::Address.latitude },
      :longitude => -> { Faker::Address.longitude },
      :username => -> { Faker::Internet.user_name },
      :boolean => -> { [true, false].sample },
      :school => -> { Faker::University.name }
    }
  end
end

ActiveSupport.on_load(:active_record) do
  extend ActsAsScrubbable::Scrubbable
end
