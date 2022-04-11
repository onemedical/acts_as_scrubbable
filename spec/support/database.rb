require 'nulldb/rails'
require 'nulldb_rspec'

if ActiveRecord::Base.configurations.respond_to?(:merge!)
  ActiveRecord::Base.configurations.merge!("test" => {adapter: 'nulldb'})
else
  ActiveRecord::Base.configurations = ActiveRecord::DatabaseConfigurations.new(test: {adapter: 'nulldb'})
end

NullDB.configure do |c|
  c.project_root = './spec'
end

RSpec.configure do |config|
  config.include include NullDB::RSpec::NullifiedDatabase
end

module ImportSupport
  def import(*, **); end
end


class NonScrubbableModel < ActiveRecord::Base; end

class ScrubbableModel < ActiveRecord::Base
  acts_as_scrubbable :first_name,
    :last_name,
    :middle_name,
    :name,
    :email,
    :company_name,
    :zip_code,
    :state,
    :city,
    :username,
    :school,
    :title => :name_title,
    :address1 => :street_address,
    :address2 => :secondary_address,
    :state_short => :state_abbr,
    :lat => :latitude,
    :lon => :longitude,
    :active => :boolean
  attr_accessor :scrubbing_begun, :scrubbing_finished
  set_callback :scrub, :before do
    self.scrubbing_begun = true
  end
  set_callback :scrub, :after do
    self.scrubbing_finished = true
  end
end
