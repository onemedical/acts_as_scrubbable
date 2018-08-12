require 'spec_helper'

RSpec.describe ActsAsScrubbable::Scrub do
  describe '.scrub' do
    # update_columns cannot be run on a new record
    subject{ ScrubbableModel.new }

    before(:each) { subject.save }

    it 'changes the first_name attribute when scrub is run' do
      subject.first_name = "Ted"
      allow(Faker::Name).to receive(:first_name).and_return("John")
      subject.scrub!
      expect(subject.first_name).to eq "John"
    end

    it 'calls street address on faker and updates address1' do
      subject.address1 = "123 abc"
      subject.save
      allow(Faker::Address).to receive(:street_address).and_return("1 Embarcadero")
      subject.scrub!
      expect(subject.address1).to eq "1 Embarcadero"
    end

    it "doesn't update the field if it's blank" do
      subject.address1 = nil
      subject.save
      allow(Faker::Address).to receive(:street_address).and_return("1 Embarcadero")
      subject.scrub!
      expect(subject.address1).to be_nil
    end

    it "doesn't update the field if the scrub type is `:skip`" do
      subject.middle_name = "Edward"
      subject.save
      subject.scrub!
      expect(subject.middle_name).to eq "Edward"
    end

    it "updates the field to nil if the scrub type is :wipe" do
      subject.last_name = "Cortéz"
      subject.save
      subject.scrub!
      expect(subject.last_name).to be_nil
    end

    it 'runs scrub callbacks' do
      subject.scrub!
      expect(subject.scrubbing_begun).to be(true)
      expect(subject.scrubbing_finished).to be(true)
    end

    context 'when sterilizable? is true' do
      subject { SterilizableModel.new }

      it 'deletes all records' do
        subject.save
        subject.scrub!
        expect(subject.class.all).to be_empty
      end
    end
  end
end
