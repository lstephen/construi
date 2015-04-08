require 'spec_helper'

RSpec.describe Construi::Runner do
  let(:config_yaml) { '{}' }
  let(:config) { Construi::Config.load(config_yaml) }

  let(:image) { instance_double(Construi::Image).as_null_object }
  let!(:image_class) { class_spy(Construi::Image).as_stubbed_const }

  [:build, :create].each do |m|
    before { allow(image_class).to receive(m).and_return image }
  end

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

    let!(:intermediate_image) { instance_double(Construi::IntermediateImage).as_null_object }
    let!(:intermediate_image_class) { class_spy(Construi::IntermediateImage).as_stubbed_const }

    before { allow(docker).to receive(:options).and_return({}) }

    before { allow(intermediate_image).to receive(:run).and_return intermediate_image }
    before { allow(intermediate_image_class).to receive(:seed).and_return intermediate_image }

    subject! { runner.run(targets) }

    it { expect(docker).to have_received(:validate_version!) }
    it { expect(intermediate_image_class).to have_received(:seed).with(image) }
    it { expect(intermediate_image).to have_received(:run).with('cmd1', []) }
    it { expect(intermediate_image).to have_received(:delete) }

    it { expect($stdout.string).to include('Running target1...'.green) }
    it { expect($stdout.string).to include(' > cmd1'.green) }
  end

  describe '#initial_image' do
    let(:build) { nil }
    let(:image) { nil }
    let(:target) { Struct.new(:build, :image).new build, image }

    subject! { runner.initial_image(target) }

    context 'when build' do
      let(:build) { 'build/dir' }

      it { is_expected.to be(image) }
      it { expect(image_class).to have_received(:build).with(build) }
      it { expect(image_class).to_not have_received(:create) }
    end

    context 'when image' do
      let(:image) { 'image:latest' }

      it { is_expected.to be(image) }
      it { expect(image_class).to have_received(:create).with(image) }
      it { expect(image_class).to_not have_received(:build) }
    end

    context 'when incorrectly configured' do
      subject { -> { runner.initial_image(target) } }
      it { expect { subject.call }.to raise_error(RuntimeError) }
    end

  end

end

