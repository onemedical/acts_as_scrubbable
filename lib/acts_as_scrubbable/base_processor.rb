module ActsAsScrubbable
  module BaseProcessor
    attr_reader :ar_class
    private :ar_class

    def initialize(ar_class)
      @ar_class = ar_class
    end

    def scrub_query(query = nil)
      scrubbed_count = 0
      ActiveRecord::Base.connection_pool.with_connection do
        if ar_class.respond_to?(:scrubbable_scope)
          relation = ar_class.send(:scrubbable_scope)
        else
          relation = ar_class.all
        end

        relation.where(query).find_in_batches(batch_size: 1000) do |batch|
          ActiveRecord::Base.transaction do
            scrubbed_count += handle_batch(batch)
          end
        end
      end
      scrubbed_count
    end
  end
end
