
require 'rake'

namespace :scrub do

  desc "scrub all"
  task all: :environment do

    require 'highline/import'
    require 'term/ansicolor'
    require 'logger'
    require 'parallel'

    @logger = Logger.new($stdout)

    answer = ask("Type SCRUB to continue.".red)
    unless answer == "SCRUB"
      puts "exiting ...".red
      exit
    end

    @logger.warn "Scrubbing classes".red

    Rails.application.eager_load! # make sure all the classes are loaded

    @total_scrubbed = 0

    ar_classes = ActiveRecord::Base.descendants.select{|d| d.scrubbable? }.sort_by{|d| d.to_s }
    Parallel.each(ar_classes) do |ar_class|

      # Removing any find or initialize callbacks from model
      ar_class.reset_callbacks(:initialize)
      ar_class.reset_callbacks(:find)

      @logger.info "Scrubbing #{ar_class} ...".green

      scrubbed_count = 0

      ActiveRecord::Base.connection_pool.with_connection do
        ar_class.find_in_batches(batch_size: 1000) do |batch|
          ActiveRecord::Base.transaction do
            batch.each do |obj|
              obj.scrub!
              scrubbed_count += 1
            end
          end
        end
      end

      @logger.info "#{scrubbed_count} #{ar_class} objects scrubbed".blue
    end

    @logger.info "Running after hook".red
    ActsAsScrubbable.execute_after_hook

    @logger.info "Scrub Complete!".white
  end
end

desc "Links to scrub:all"
task :scrub => ['scrub:all']
