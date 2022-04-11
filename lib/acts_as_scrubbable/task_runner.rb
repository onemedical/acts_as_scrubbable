require 'acts_as_scrubbable/parallel_table_scrubber'
require 'highline/import'
require 'acts_as_scrubbable/ar_class_processor'
require 'term/ansicolor'

module ActsAsScrubbable
  class TaskRunner
    attr_reader :ar_classes
    private :ar_classes

    def initialize
      @ar_classes = []
    end

    def prompt_db_configuration
      db_host = ActiveRecord::Base.connection_config[:host]
      db_name = ActiveRecord::Base.connection_config[:database]

      ActsAsScrubbable.logger.warn Term::ANSIColor.red("Please verify the information below to continue")
      ActsAsScrubbable.logger.warn Term::ANSIColor.red("Host: ") + Term::ANSIColor.white(" #{db_host}")
      ActsAsScrubbable.logger.warn Term::ANSIColor.red("Database: ") + Term::ANSIColor.white("#{db_name}")
    end

    def confirmed_configuration?
      db_host = ActiveRecord::Base.connection_config[:host]

      unless ENV["SKIP_CONFIRM"] == "true"
        answer = ask("Type '#{db_host}' to continue. \n".red + '-> '.white)
        unless answer == db_host
          ActsAsScrubbable.logger.error Term::ANSIColor.red("exiting ...")
          return false
        end
      end
      true
    end

    def extract_ar_classes
      Rails.application.eager_load! # make sure all the classes are loaded
      @ar_classes = ActiveRecord::Base.descendants.select { |d| d.scrubbable? }.sort_by { |d| d.to_s }

      if ENV["SCRUB_CLASSES"].present?
        class_list = ENV["SCRUB_CLASSES"].split(",")
        class_list = class_list.map { |_class_str| _class_str.constantize }
        @ar_classes = ar_classes & class_list
      end
    end

    def set_ar_class(ar_class)
      ar_classes << ar_class
    end

    def scrub(num_of_batches: nil)
      Parallel.each(ar_classes) do |ar_class|
        ActsAsScrubbable::ArClassProcessor.new(ar_class).process(num_of_batches)
      end
      ActiveRecord::Base.connection.verify!

      after_hooks
    end

    def after_hooks
      if ENV["SKIP_AFTERHOOK"].blank?
        ActsAsScrubbable.logger.info Term::ANSIColor.red("Running after hook")
        ActsAsScrubbable.execute_after_hook
      end
    end
  end
end