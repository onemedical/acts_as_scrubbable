require 'spec_helper'

RSpec.describe ActsAsScrubbable::ArClassProcessor do
  let(:ar_class) { ScrubbableModel }

  describe "#initialize" do
    subject { described_class.new(ar_class) }

    context "with upsert enabled" do
      before do
        allow(ActsAsScrubbable).to receive(:use_upsert).and_return(true)
      end

      it "includes the ImportProcessor module" do
        expect(subject.query_processor).to be_kind_of(ActsAsScrubbable::ImportProcessor)
      end
    end

    context "without upsert enabled" do
      it "includes the UpdateProcessor module" do
        expect(subject.query_processor).to be_kind_of(ActsAsScrubbable::UpdateProcessor)
      end
    end
  end

  describe "#process" do
    let(:num_of_batches) { nil }
    let(:query) { nil }
    let(:parallel_table_scrubber_mock) { instance_double("ParallelTableScrubber") }
    let(:update_processor_mock) { instance_double("UpdateProcessor", scrub_query: nil) }
    subject { described_class.new(ar_class) }

    before do
      allow(ActsAsScrubbable::ParallelTableScrubber).to receive(:new).and_return(parallel_table_scrubber_mock)
      allow(ActsAsScrubbable::UpdateProcessor).to receive(:new).and_return(update_processor_mock)
      allow(parallel_table_scrubber_mock).to receive(:each_query).and_yield(query)
    end

    it "calls the expected helper classes with the expected batch size" do
      expect(update_processor_mock).to receive(:scrub_query).with(query)
      subject.process(num_of_batches)
      expect(ActsAsScrubbable::ParallelTableScrubber).to have_received(:new).with(ar_class, 256)
    end

    context "with an inputted batch size" do
      let(:num_of_batches) { 10 }

      it "calls ParallelTableScrubber with the passed batch size" do
        subject.process(num_of_batches)
        expect(ActsAsScrubbable::ParallelTableScrubber).to have_received(:new).with(ar_class, num_of_batches)
      end
    end

  end
end