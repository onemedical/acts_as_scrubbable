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
        subject.scrub!
      }.not_to raise_error
    end

    it 'changes the first_name attribute when scrub is run' do
      subject.first_name = "Ted"
      allow(Faker::Name).to receive(:first_name).and_return("John")
      _updates = subject.scrub!
      expect(_updates[:first_name]).to eq "John"
    end

    it 'calls street address on faker and updates address1' do
      subject.address1 = "123 abc"
      subject.save
      allow(Faker::Address).to receive(:street_address).and_return("1 Embarcadero")
      _updates = subject.scrub!
      expect(_updates[:address1]).to eq "1 Embarcadero"
    end

    it "doesn't update the field if it's blank" do
      subject.address1 = nil
      subject.save
      allow(Faker::Address).to receive(:street_address).and_return("1 Embarcadero")
      subject.scrub!
      expect(subject.address1).to be_nil
    end

    it 'runs scrub callbacks' do
      subject.scrub!
      expect(subject.scrubbing_begun).to be(true)
      expect(subject.scrubbing_finished).to be(true)
    end
  end
end
