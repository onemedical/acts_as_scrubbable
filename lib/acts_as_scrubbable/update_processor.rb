require 'acts_as_scrubbable/base_processor'

module ActsAsScrubbable
  module UpdateProcessor
    include BaseProcessor

    def handle_batch(batch)
      scrubbed_count = 0
      batch.each do |obj|
        _updates = obj.scrubbed_values
        obj.update_columns(_updates) unless _updates.empty?
        scrubbed_count += 1
      end
      scrubbed_count
    end
  end
end
