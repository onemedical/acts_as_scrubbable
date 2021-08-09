require 'acts_as_scrubbable/parallel_table_scrubber'

require 'highline/import'
require 'acts_as_scrubbable/ar_class_processor'

module ActsAsScrubbable
  class TaskRunner


    attr_reader :ar_classes, :processor
    private :ar_classes, :processor

    def initialize
      @ar_classes = []
    end

    def prompt_db_configuration
      db_host = ActiveRecord::Base.connection_config[:host]
      db_name = ActiveRecord::Base.connection_config[:database]

      ActsAsScrubbable.logger.warn "Please verify the information below to continue".red
      ActsAsScrubbable.logger.warn "Host: ".red + " #{db_host}".white
      ActsAsScrubbable.logger.warn "Database: ".red + "#{db_name}".white
    end

    def confirmed_configuration?
      db_host = ActiveRecord::Base.connection_config[:host]

      unless ENV["SKIP_CONFIRM"] == "true"
        answer = ask("Type '#{db_host}' to continue. \n".red + '-> '.white)
        unless answer == db_host
          ActsAsScrubbable.logger.error "exiting ...".red
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
    end

    def after_hooks
      if ENV["SKIP_AFTERHOOK"].blank?
        ActsAsScrubbable.logger.info "Running after hook".red
        ActsAsScrubbable.execute_after_hook
      end
    end
  end
end