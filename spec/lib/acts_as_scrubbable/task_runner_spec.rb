require "spec_helper"

RSpec.describe ActsAsScrubbable::TaskRunner do
  subject(:runner) { described_class.new }

  let(:logger) { instance_double("Logger", error: nil, info: nil, warn: nil) }
  before do
    allow(ActsAsScrubbable).to receive(:logger).and_return(logger)
  end

  describe "#prompt_db_configuration" do
    it "reports database host and name" do
      runner.prompt_db_configuration
      expect(logger).to have_received(:warn).with(/Host:/)
      expect(logger).to have_received(:warn).with(/Database:/)
    end
  end

  describe "#confirmed_configuration?" do
    before do
      allow(runner).to receive(:ask).and_return(answer)
    end

    context "when answer matches database host" do
      let(:answer) { ActiveRecord::Base.connection_db_config.host }

      it "is true" do
        expect(runner).to be_confirmed_configuration
      end
    end

    context "when answer does not match database host" do
      let(:answer) { "anything else" }

      it "is false" do
        expect(runner).not_to be_confirmed_configuration
      end
    end
  end

  describe "#scrub" do
    let(:application) { instance_double("Rails::Application", eager_load!: nil) }
    let(:processor) { instance_double("ActsAsScrubbable::ArClassProcessor", process: nil) }
    before do
      allow(Rails).to receive(:application).and_return(application)
      allow(ActsAsScrubbable::ArClassProcessor).to receive(:new).and_return(processor)
      # RSpec mocks are not tracking calls across the forks that Parallel creates, so stub it out
      allow(Parallel).to receive(:each) do |array, &block|
        array.each(&block)
      end
    end

    it "scrubs all scrubbable classes", :aggregate_failures do
      runner.extract_ar_classes
      runner.scrub(num_of_batches: 1)
      expect(processor).to have_received(:process).with(1).exactly(4).times
      expect(ActsAsScrubbable::ArClassProcessor).to have_received(:new).with(ScrubbableModel)
      expect(ActsAsScrubbable::ArClassProcessor).to have_received(:new).with(AnotherScrubbableModel)
      expect(ActsAsScrubbable::ArClassProcessor).to have_received(:new).with(AThirdScrubbableModel)
      expect(ActsAsScrubbable::ArClassProcessor).to have_received(:new).with(MissingScrubbableModel)
      expect(ActsAsScrubbable::ArClassProcessor).not_to have_received(:new).with(NonScrubbableModel)
    end

    context "if SCRUB_CLASSES is set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SCRUB_CLASSES").and_return(
          "NonScrubbableModel,ScrubbableModel,AThirdScrubbableModel",
        )
        runner.extract_ar_classes
      end

      it "only scrubs specified scrubbable classes" do
        runner.scrub
        expect(processor).to have_received(:process).twice
        expect(ActsAsScrubbable::ArClassProcessor).to have_received(:new).with(ScrubbableModel)
        expect(ActsAsScrubbable::ArClassProcessor).to have_received(:new).with(AThirdScrubbableModel)
        expect(ActsAsScrubbable::ArClassProcessor).not_to have_received(:new).with(AnotherScrubbableModel)
        expect(ActsAsScrubbable::ArClassProcessor).not_to have_received(:new).with(NonScrubbableModel)
      end
    end

    context "if a specific class is set" do
      before do
        runner.set_ar_class(AnotherScrubbableModel)
      end

      it "only scrubs the specified class" do
        runner.scrub
        expect(processor).to have_received(:process).once
        expect(ActsAsScrubbable::ArClassProcessor).to have_received(:new).with(AnotherScrubbableModel)
        expect(ActsAsScrubbable::ArClassProcessor).not_to have_received(:new).with(ScrubbableModel)
        expect(ActsAsScrubbable::ArClassProcessor).not_to have_received(:new).with(AThirdScrubbableModel)
        expect(ActsAsScrubbable::ArClassProcessor).not_to have_received(:new).with(NonScrubbableModel)
      end
    end
  end

  describe "#before_hooks" do
    before do
      allow(ActsAsScrubbable).to receive(:execute_before_hook)
    end

    it "executes before hook" do
      runner.before_hooks
      expect(ActsAsScrubbable).to have_received(:execute_before_hook)
    end

    context "if SKIP_BEFOREHOOK is set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SKIP_BEFOREHOOK").and_return("true")
      end

      it "does nothing" do
        runner.before_hooks
        expect(ActsAsScrubbable).not_to have_received(:execute_before_hook)
      end
    end
  end

  describe "#after_hooks" do
    before do
      allow(ActsAsScrubbable).to receive(:execute_after_hook)
    end

    it "executes after hook" do
      runner.after_hooks
      expect(ActsAsScrubbable).to have_received(:execute_after_hook)
    end

    context "if SKIP_AFTERHOOK is set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("SKIP_AFTERHOOK").and_return("true")
      end

      it "does nothing" do
        runner.after_hooks
        expect(ActsAsScrubbable).not_to have_received(:execute_after_hook)
      end
    end
  end
end
