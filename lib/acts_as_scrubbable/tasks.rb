
require 'rake'

namespace :scrub do

  desc "scrub all scrubbable tables"
  task all: :environment do
    require 'highline/import'
    require 'term/ansicolor'
    require 'logger'
    require 'parallel'

    include Term::ANSIColor

    logger = Logger.new($stdout)
    logger.formatter = proc do |severity, datetime, progname, msg|
       "#{datetime}: [#{severity}] - #{msg}\n"
    end

    db_host = ActiveRecord::Base.connection_config[:host]
    db_name = ActiveRecord::Base.connection_config[:database]

    logger.warn "Please verify the information below to continue".red
    logger.warn "Host: ".red + " #{db_host}".white
    logger.warn "Database: ".red + "#{db_name}".white

    unless ENV["SKIP_CONFIRM"] == "true"
      answer = ask("Type '#{db_host}' to continue. \n".red + '-> '.white)
      unless answer == db_host
        logger.error "exiting ...".red
        exit
      end
    end

    logger.warn "Scrubbing classes".red

    Rails.application.eager_load! # make sure all the classes are loaded

    ar_classes = ActiveRecord::Base.descendants.select{|d| d.scrubbable? }.sort_by{|d| d.to_s }

    if ENV["SCRUB_CLASSES"].present?
      class_list = ENV["SCRUB_CLASSES"].split(",")
      class_list = class_list.map {|_class_str| _class_str.constantize }
      ar_classes = ar_classes & class_list
    end

    logger.info "Scrubbable Classes: #{ar_classes.join(', ')}".white

    Parallel.each(ar_classes) do |ar_class|
      # Removing any find or initialize callbacks from model
      ar_class.reset_callbacks(:initialize)
      ar_class.reset_callbacks(:find)

      logger.info "Scrubbing #{ar_class} ...".green

      scrubbed_count = 0

      ActiveRecord::Base.connection_pool.with_connection do
        if ar_class.respond_to?(:scrubbable_scope)
          relation = ar_class.send(:scrubbable_scope)
        else
          relation = ar_class.all
        end

        relation.find_in_batches(batch_size: 1000) do |batch|
          ActiveRecord::Base.transaction do
            batch.each do |obj|
              obj.scrub!
              scrubbed_count += 1
            end
          end
        end
      end

      logger.info "#{scrubbed_count} #{ar_class} objects scrubbed".blue
    end
    ActiveRecord::Base.connection.verify!

    if ENV["SKIP_AFTERHOOK"].blank?
      logger.info "Running after hook".red
      ActsAsScrubbable.execute_after_hook
    end

    logger.info "Scrub Complete!".white
  end

  desc "Scrub one table"
  task :model, [:ar_class] => :environment do |_, args|
    require 'highline/import'
    require 'term/ansicolor'
    require 'logger'
    require 'acts_as_scrubbable/parallel_table_scrubber'

    include Term::ANSIColor

    logger = Logger.new($stdout)
    logger.formatter = proc do |severity, datetime, progname, msg|
       "#{datetime}: [#{severity}] - #{msg}\n"
    end

    db_host = ActiveRecord::Base.connection_config[:host]
    db_name = ActiveRecord::Base.connection_config[:database]

    logger.warn "Please verify the information below to continue".red
    logger.warn "Host: ".red + " #{db_host}".white
    logger.warn "Database: ".red + "#{db_name}".white

    unless ENV["SKIP_CONFIRM"] == "true"
      answer = ask("Type '#{db_host}' to continue. \n".red + '-> '.white)
      unless answer == db_host
        logger.error "exiting ...".red
        exit
      end
    end

    Rails.application.eager_load! # make sure all the classes are loaded

    ar_class = args[:ar_class].constantize
    logger.info "Scrubbing #{ar_class} ...".green

    num_batches = Integer(ENV.fetch("SCRUB_BATCHES", "256"))
    scrubbed_count = ActsAsScrubbable::ParallelTableScrubber.new(ar_class).scrub(num_batches: num_batches)

    logger.info "#{scrubbed_count} #{ar_class} objects scrubbed".blue
    ActiveRecord::Base.connection.verify!

    logger.info "Scrub Complete!".white
  end
end

desc "Links to scrub:all"
task :scrub => ['scrub:all']
