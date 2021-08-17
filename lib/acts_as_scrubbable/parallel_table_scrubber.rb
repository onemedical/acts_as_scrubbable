require "parallel"

module ActsAsScrubbable
  class ParallelTableScrubber
    attr_reader :ar_class, :num_of_batches
    private :ar_class, :num_of_batches

    def initialize(ar_class, num_of_batches)
      @ar_class = ar_class
      @num_of_batches = num_of_batches
    end

    def each_query
      # Removing any find or initialize callbacks from model
      ar_class.reset_callbacks(:initialize)
      ar_class.reset_callbacks(:find)

      Parallel.map(parallel_queries) { |query|
        yield(query)
      }.reduce(:+) # returns the aggregated scrub count
    end

    private

    # create even ID ranges for the table
    def parallel_queries
      raise "Model is missing id column" if ar_class.columns.none? { |column| column.name == "id" }

      if ar_class.respond_to?(:scrubbable_scope)
        num_records = ar_class.send(:scrubbable_scope).count
      else
        num_records = ar_class.count
      end
      return [] if num_records == 0 # no records to import

      record_window_size, modulus = num_records.divmod(num_of_batches)
      if record_window_size < 1
        record_window_size = 1
        modulus = 0
      end

      start_id = next_id(ar_class: ar_class, offset: 0)
      queries = num_of_batches.times.each_with_object([]) do |_, queries|
        next unless start_id

        end_id = next_id(ar_class: ar_class, id: start_id, offset: record_window_size - 1)
        if modulus > 0
          end_id = next_id(ar_class: ar_class, id: end_id)
          modulus -= 1
        end
        queries << { id: start_id..end_id } if end_id
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
