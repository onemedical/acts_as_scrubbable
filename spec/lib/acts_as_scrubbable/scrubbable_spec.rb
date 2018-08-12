require 'spec_helper'

RSpec.describe ActsAsScrubbable::Scrubbable do
  context "not scrubbable" do
    subject { NonScrubbableModel.new }

    describe "scrubbable?" do
      it 'returns false' do
        expect(subject.class.scrubbable?).to eq false
      end
    end
  end

  context "scrubbable" do
    subject { ScrubbableModel.new }

    describe "scrubbable?" do
      it 'returns true' do
        expect(subject.class.scrubbable?).to eq true
      end
    end

    describe "scrubbable_fields" do
      it 'returns the list of scrubbable fields' do
        expect(subject.scrubbable_fields.keys).to match_array(%i[first_name middle_name last_name address1 lat])
      end
    end

    describe "sterilizable?" do
      it 'returns false' do
        expect(subject.class.sterilizable?).to eq false
      end

      context "when :sterilize is passed as a scrub_type" do
        subject { SterilizableModel.new }

        it 'returns true' do
          expect(subject.class.sterilizable?).to eq true
        end
      end
    end
  end
end
