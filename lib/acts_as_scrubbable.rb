require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'
require 'acts_as_scrubbable/tasks'


module ActsAsScrubbable
  extend ActiveSupport::Autoload

  autoload :Scrubbable
  autoload :Scrub
  autoload :VERSION
end


ActiveSupport.on_load(:active_record) do
  extend ActsAsScrubbable::Scrubbable
end
