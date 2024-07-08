require 'spec_helper'

RSpec.describe ActsAsScrubbable::Scrub do

  describe '.scrub' do

    # update_columns cannot be run on a new record
    subject { ScrubbableModel.new }
    before(:each) { subject.save }

    it 'scrubs all columns' do
      subject.attributes = {
        first_name: "Ted",
        last_name: "Lowe",
        middle_name: "Cassidy",
        name: "Miss Vincenzo Smitham",
        email: "trentdibbert@wiza.com",
        title: "Internal Consultant",
        company_name: "Greenfelder, Collier and Lesch",
        address1: "86780 Watsica Flats",
        address2: "Apt. 913",
        zip_code: "49227",
        state: "Ohio",
        state_short: "OH",
        city: "Port Hildegard",
        lat: -79.5855309778974,
        lon: 13.517352691513906,
        username: "oscar.hermann",
        active: false,
        school: "Eastern Lebsack",
      }
      expect {
        subject.scrubbed_values
      }.not_to raise_error
    end

    it 'changes the first_name attribute when scrub is run' do
      subject.first_name = "Ted"
      allow(Faker::Name).to receive(:first_name).and_return("John")
      _updates = subject.scrubbed_values
      expect(_updates[:first_name]).to eq "John"
    end

    it 'calls street address on faker and updates address1' do
      subject.address1 = "123 abc"
      subject.save
      allow(Faker::Address).to receive(:street_address).and_return("1 Embarcadero")
      _updates = subject.scrubbed_values
      expect(_updates[:address1]).to eq "1 Embarcadero"
    end

    it "doesn't update the field if it's blank" do
      subject.address1 = nil
      subject.save
      allow(Faker::Address).to receive(:street_address).and_return("1 Embarcadero")
      _updates = subject.scrubbed_values
      expect(_updates[:address1]).to be_nil
    end

    it 'output no information when all scrubbers found' do
      expect(STDOUT).to_not receive(:puts)

      _updates = subject.scrubbed_values
    end

    context "scrubbable" do
      subject { MissingScrubbableModel.new }

      it 'outputs warning message' do
        subject.first_name = "Johnny"
        subject.last_name = "Frank"

        allow(Faker::Name).to receive(:first_name).and_return("Larry")
        allow(Faker::Name).to receive(:last_name).and_return("Baker")

        expect(STDOUT).to receive(:puts).with('Undefined scrub: fake_first_name for MissingScrubbableModel.first_name')
        expect(Faker::Name).to_not receive(:first_name)

        _updates = subject.scrubbed_values
        expect(_updates[:last_name]).to eq('Baker')
        expect(_updates[:first_name]).to be_nil
      end
    end
  end
end
