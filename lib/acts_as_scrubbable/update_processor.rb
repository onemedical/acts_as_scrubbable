require 'acts_as_scrubbable/base_processor'

module ActsAsScrubbable
  class UpdateProcessor
    include BaseProcessor

    private
    def handle_batch(batch)
      scrubbed_count = 0
      batch.each do |obj|
        _updates = obj.scrub!
        obj.update_columns(_updates) unless _updates.empty?
        scrubbed_count += 1
      end
      scrubbed_count
    end
  end
end
