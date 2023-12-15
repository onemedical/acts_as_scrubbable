require 'acts_as_scrubbable/import_processor'
require 'acts_as_scrubbable/update_processor'
require 'term/ansicolor'

module ActsAsScrubbable
  class ArClassProcessor

    attr_reader :ar_class, :query_processor

    def initialize(ar_class)
      @ar_class = ar_class

      if ActsAsScrubbable.use_upsert
        ActsAsScrubbable.logger.info Term::ANSIColor.white("Using Upsert")
        @query_processor = ImportProcessor.new(ar_class)
      else
        ActsAsScrubbable.logger.info Term::ANSIColor.white("Using Update")
        @query_processor = UpdateProcessor.new(ar_class)
      end
    end

    def process(num_of_batches)
      ActsAsScrubbable.logger.info Term::ANSIColor.green("Scrubbing #{ar_class} ...")

      num_of_batches = Integer(ENV.fetch("SCRUB_BATCHES", "256")) if num_of_batches.nil?
      scrubbed_count = ActsAsScrubbable::ParallelTableScrubber.new(ar_class, num_of_batches).each_query do |query|
        query_processor.scrub_query(query)
      end

      ActsAsScrubbable.logger.info Term::ANSIColor.blue("#{scrubbed_count} #{ar_class} objects scrubbed")
      ActiveRecord::Base.connection.verify! if ActiveRecord::Base.connection.respond_to?(:reconnect)

      ActsAsScrubbable.logger.info Term::ANSIColor.white("Scrub Complete!")
    end
  end
end
