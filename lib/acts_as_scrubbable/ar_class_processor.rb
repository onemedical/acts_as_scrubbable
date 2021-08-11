require 'acts_as_scrubbable/import_processor'
require 'acts_as_scrubbable/update_processor'

module ActsAsScrubbable
  class ArClassProcessor
    attr_reader :ar_class, :query_processor

    def initialize(ar_class)
      @ar_class = ar_class

      if ActsAsScrubbable.use_upsert
        ActsAsScrubbable.logger.info "Using Upsert".white
        @query_processor = ImportProcessor.new(ar_class)
      else
        ActsAsScrubbable.logger.info "Using Update".white
        @query_processor = UpdateProcessor.new(ar_class)
      end
    end

    def process(num_of_batches)
      ActsAsScrubbable.logger.info "Scrubbing #{ar_class} ...".green

      num_of_batches = Integer(ENV.fetch("SCRUB_BATCHES", "256")) if num_of_batches.nil?
      scrubbed_count = ActsAsScrubbable::ParallelTableScrubber.new(ar_class, num_of_batches).each_query do |query|
        query_processor.scrub_query(query)
      end

      ActsAsScrubbable.logger.info "#{scrubbed_count} #{ar_class} objects scrubbed".blue
      ActiveRecord::Base.connection.verify!

      ActsAsScrubbable.logger.info "Scrub Complete!".white
    end
  end
end
