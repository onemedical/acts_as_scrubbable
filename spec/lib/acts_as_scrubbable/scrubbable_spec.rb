require 'spec_helper'

RSpec.describe ActsAsScrubbable::Scrubbable do

  context "not scrubbable" do
    subject {NonScrubbableModel.new}

    describe "scrubbable?" do
      it 'returns false' do
        expect(subject.class.scrubbable?).to eq false
      end
    end
  end


  context "scrubbable" do
    subject {ScrubbableModel.new}

    describe "scrubbable?" do
      it 'returns false' do
        expect(subject.class.scrubbable?).to eq true
      end
    end


    describe "scrubbable_fields" do
      it 'returns the list of scrubbable fields' do
        expect(subject.scrubbable_fields.keys.first).to eq :first_name
      end
    end

  end
end
