require 'acts_as_scrubbable/import_processor'
require 'acts_as_scrubbable/update_processor'

module ActsAsScrubbable
  class ArClassProcessor
    attr_reader :ar_class
    private :ar_class

    def initialize(ar_class)
      @ar_class = ar_class

      self.class_eval do
        if ar_class.respond_to?(:import) && ActiveRecord::Base.connection_config[:adapter].include?("mysql")
          include ImportProcessor
        else
          include UpdateProcessor
        end
      end
    end

    def process(num_of_batches)
      # Removing any find or initialize callbacks from model
      ar_class.reset_callbacks(:initialize)
      ar_class.reset_callbacks(:find)

      ActsAsScrubbable.logger.info "Scrubbing #{ar_class} ...".green

      num_of_batches = Integer(ENV.fetch("SCRUB_BATCHES", "256")) if num_of_batches.nil?
      scrubbed_count = ActsAsScrubbable::ParallelTableScrubber.new(ar_class, num_of_batches).each_query do |query|
        scrub_query(query)
      end

      ActsAsScrubbable.logger.info "#{scrubbed_count} #{ar_class} objects scrubbed".blue
      ActiveRecord::Base.connection.verify!

      ActsAsScrubbable.logger.info "Scrub Complete!".white
    end
  end
end
