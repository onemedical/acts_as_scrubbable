require 'nulldb/rails'
require 'nulldb_rspec'

ActiveRecord::Base.configurations = {"test" => {adapter: :nulldb}}

NullDB.configure do |c|
  c.project_root = './spec'
end

RSpec.configure do |config|
  config.include include NullDB::RSpec::NullifiedDatabase
end


class NonScrubbableModel < ActiveRecord::Base; end

class ScrubbableModel < ActiveRecord::Base
  acts_as_scrubbable :first_name, address1: :street_address
end
