require 'spec_helper'

RSpec.describe ActsAsScrubbable::UpdateProcessor do
  let(:ar_class) { ScrubbableModel }
  let(:model) { ar_class.create(
    first_name: "Ted",
    last_name: "Lowe",
  ) }
  subject { described_class.new(ar_class) }

  describe "#handle_batch" do
    it "calls update with the updated attributes" do
      expect(model).to receive(:scrubbed_values).and_call_original
      expect(model).to receive(:update_columns).and_call_original

      expect(subject.send(:handle_batch, [model])).to eq 1
    end

    it "runs scrub callbacks" do
      subject.send(:handle_batch, [model])
      expect(model.scrubbing_begun).to be(true)
      expect(model.scrubbing_finished).to be(true)
    end
  end
end
