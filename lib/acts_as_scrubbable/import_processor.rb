require 'acts_as_scrubbable/base_processor'

module ActsAsScrubbable
  class ImportProcessor
    include BaseProcessor

    private
    def handle_batch(batch)
      scrubbed_count = 0
      batch.each do |obj|
        _updates = obj.scrubbed_values
        obj.assign_attributes(_updates)
        scrubbed_count += 1
      end
      ar_class.import(
        batch,
        on_duplicate_key_update: ar_class.scrubbable_fields.keys.map { |x| "#{x} = values(#{x})" }.join(" , "),
        validate: false,
        timestamps: false
      )
      scrubbed_count
    end
  end
end
