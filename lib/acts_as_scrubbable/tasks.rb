require 'rake'
require 'acts_as_scrubbable/task_runner'

namespace :scrub do

  desc "scrub all scrubbable tables"
  task all: :environment do
    task_runner = ActsAsScrubbable::TaskRunner.new
    task_runner.prompt_db_configuration
    exit unless task_runner.confirmed_configuration?
    task_runner.extract_ar_classes
    task_runner.scrub(num_of_batches: 1)
    task_runner.after_hooks
  end

  desc "Scrub one table"
  task :model, [:ar_class] => :environment do |_, args|
    task_runner = ActsAsScrubbable::TaskRunner.new
    task_runner.prompt_db_configuration
    exit unless task_runner.confirmed_configuration?
    task_runner.set_ar_class(args[:ar_class].constantize)
    task_runner.scrub
  end
end

desc "Links to scrub:all"
task :scrub => ['scrub:all']
