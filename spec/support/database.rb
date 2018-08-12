require 'nulldb/rails'
require 'nulldb_rspec'

ActiveRecord::Base.configurations.merge!("test" => { adapter: 'nulldb' })

NullDB.configure do |c|
  c.project_root = './spec'
end

RSpec.configure do |config|
  config.include include NullDB::RSpec::NullifiedDatabase
end

class NonScrubbableModel < ActiveRecord::Base; end

class ScrubbableModel < ActiveRecord::Base
  attr_accessor :scrubbing_begun, :scrubbing_finished

  acts_as_scrubbable :scrub, :first_name, :address1 => :street_address, :lat => :latitude
  acts_as_scrubbable :wipe, :last_name
  acts_as_scrubbable :skip, :middle_name

  set_callback :scrub, :before do
    self.scrubbing_begun = true
  end

  set_callback :scrub, :after do
    self.scrubbing_finished = true
  end
end

class SterilizableModel < ActiveRecord::Base
  acts_as_scrubbable :sterilize
end
