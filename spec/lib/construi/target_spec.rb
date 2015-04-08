require 'spec_helper'

RSpec.describe Construi::Target do
  subject(:config) do
    cfg = {}
    cfg['image'] = image unless image.nil?
    cfg['build'] = build unless build.nil?
    cfg
  end

  subject(:target) { Construi::Target.new(nil, config, Construi::Config.load('{}')) }

  describe '#initial_image' do
    let!(:image_class) { class_spy(Construi::Image).as_stubbed_const }
    let(:construi_image) { instance_double(Construi::Image).as_null_object }

    [:build, :create].each do |m|
      before { allow(image_class).to receive(m).and_return construi_image }
    end

    let(:build) { nil }
    let(:image) { nil }

    subject! { target.initial_image }

    context 'when build' do
      let(:build) { 'build/dir' }

      it { is_expected.to be(construi_image) }
      it { expect(image_class).to have_received(:build).with(build) }
      it { expect(image_class).to_not have_received(:create) }
    end

    context 'when image' do
      let(:image) { 'image:latest' }

      it { is_expected.to be(construi_image) }
      it { expect(image_class).to have_received(:create).with(image) }
      it { expect(image_class).to_not have_received(:build) }
    end

    context 'when incorrectly configured' do
      subject { -> { target.initial_image } }
      it { expect { subject.call }.to raise_error(RuntimeError) }
    end

  end
end
