require 'spec_helper'

RSpec.describe ActsAsScrubbable::ImportProcessor do
  let(:ar_class) { ScrubbableModel }
  let(:model) { ar_class.new }
  subject { described_class.new(ar_class) }

  before do
    ar_class.extend(ImportSupport)
  end

  describe "#handle_batch" do
    it "calls import with the correct parameters" do
      expect(model).to receive(:scrubbed_values).and_call_original
      expect(ar_class).to receive(:import).with(
        [model],
        on_duplicate_key_update: "`first_name` = values(`first_name`) , `last_name` = values(`last_name`) , `middle_name` = values(`middle_name`) , `name` = values(`name`) , `email` = values(`email`) , `company_name` = values(`company_name`) , `zip_code` = values(`zip_code`) , `state` = values(`state`) , `city` = values(`city`) , `username` = values(`username`) , `school` = values(`school`) , `title` = values(`title`) , `address1` = values(`address1`) , `address2` = values(`address2`) , `state_short` = values(`state_short`) , `lat` = values(`lat`) , `lon` = values(`lon`) , `active` = values(`active`)",
        validate: false,
        timestamps: false
      )

      expect(subject.send(:handle_batch, [model])).to eq 1
    end
  end
end