require 'spec_helper'

RSpec.describe Construi::Runner do
  let(:config_yaml) { '{}' }
  let(:config) { Construi::Config.load(config_yaml) }

  let(:image) { instance_double(Construi::Image).as_null_object }
  let!(:image_class) { class_spy(Construi::Image).as_stubbed_const }

  before { allow(image_class).to receive(:from).and_return image }

  subject(:runner) { Construi::Runner.new(config) }

  describe '#run' do
    let(:config_yaml) do
      <<-YAML
      image: image:latest
      targets:
        target1: cmd1
      YAML
    end

    let(:targets) { ['target1'] }

    let!(:docker) { class_spy(Docker).as_stubbed_const }

    before { allow(docker).to receive(:options).and_return({}) }

    before { allow(image).to receive(:run).and_return image }
    before { allow(image).to receive(:tagged?).and_return false }

    subject! { runner.run(targets) }

    it { expect(docker).to have_received(:validate_version!) }
    it { expect(image).to have_received(:run).with('cmd1', env: []) }
    it { expect(image).to have_received(:delete) }

    it { expect($stdout.string).to include('Running target1...'.green) }
    it { expect($stdout.string).to include(' > cmd1'.green) }
  end


end

