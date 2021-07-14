require "parallel"

module ActsAsScrubbable
  class ParallelTableScrubber
    def initialize(ar_class)
      @ar_class = ar_class
    end

    def scrub(num_batches:)
      # Removing any find or initialize callbacks from model
      ar_class.reset_callbacks(:initialize)
      ar_class.reset_callbacks(:find)

      queries = parallel_queries(ar_class: ar_class, num_batches: num_batches)
      scrubbed_count = Parallel.map(queries) { |query|
        scrubbed_count = 0
        ActiveRecord::Base.connection_pool.with_connection do
          relation = ar_class
          relation = relation.send(:scrubbable_scope) if ar_class.respond_to?(:scrubbable_scope)
          relation.where(query).find_in_batches(batch_size: 1000) do |batch|
            ActiveRecord::Base.transaction do
              batch.each do |obj|
                obj.scrub!
                scrubbed_count += 1
              end
            end
          end
        end
        scrubbed_count
      }.reduce(:+)
    end

    private

    attr_reader :ar_class

    # create even ID ranges for the table
    def parallel_queries(ar_class:, num_batches:)
      raise "Model is missing id column" if ar_class.columns.none? { |column| column.name == "id" }

      if ar_class.respond_to?(:scrubbable_scope)
        num_records = ar_class.send(:scrubbable_scope).count
      else
        num_records = ar_class.count
      end
      return [] if num_records == 0 # no records to import

      record_window_size, modulus = num_records.divmod(num_batches)
      if record_window_size < 1
        record_window_size = 1
        modulus = 0
      end

      start_id = next_id(ar_class: ar_class, offset: 0)
      queries = num_batches.times.each_with_object([]) do |_, queries|
        next unless start_id

        end_id = next_id(ar_class: ar_class, id: start_id, offset: record_window_size-1)
        if modulus > 0
          end_id = next_id(ar_class: ar_class, id: end_id)
          modulus -= 1
        end
        queries << {id: start_id..end_id} if end_id
        start_id = next_id(ar_class: ar_class, id: end_id || start_id)
      end

      # just in case new records are added since we started, extend the end ID
      queries[-1] = ["#{ar_class.quoted_table_name}.id >= ?", queries[-1][:id].begin] if queries.any?

      queries
    end

    def next_id(ar_class:, id: nil, offset: 1)
      if ar_class.respond_to?(:scrubbable_scope)
        collection = ar_class.send(:scrubbable_scope)
      else
        collection = ar_class.all
      end
      collection = collection.reorder(:id)
      collection = collection.where("#{ar_class.quoted_table_name}.id >= :id", id: id) if id
      collection.offset(offset).limit(1).pluck(:id).first
    end
  end
end
