require 'acts_as_scrubbable/base_processor'

module ActsAsScrubbable
  class UpdateProcessor
    include BaseProcessor

    private
    def handle_batch(batch)
      scrubbed_count = 0
      batch.each do |obj|
        obj.run_callbacks(:scrub) do
          _updates = obj.scrubbed_values
          obj.update_columns(_updates) unless _updates.empty?
        end
        scrubbed_count += 1
      end
      scrubbed_count
    end
  end
end
