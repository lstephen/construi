
require 'spec_helper'
require 'construi/image'

RSpec.describe Construi::Image do
  let(:docker_image) { instance_double(Docker::Image).as_null_object }

  subject(:image) { Construi::Image.wrap(docker_image) }

  describe '#id' do
    let(:id) { 'test_id' }

    before { allow(docker_image).to receive(:id).and_return id }

    subject { image.id }

    it { is_expected.to eq(id) }
  end

  describe '#delete' do
    subject! { image.delete }
    it { expect(docker_image).to have_received(:delete) }
  end

  describe '#tagged?' do
    before do
      allow(docker_image).to receive(:info).and_return({ 'RepoTags' => tag })
    end

    subject { image.tagged? }

    context 'tagged' do
      let(:tag) { 'tagged:latest' }
      it { is_expected.to be(true) }
    end

    context 'not tagged' do
      let(:tag) { '<none>:<none>' }
      it { is_expected.to be(false) }
    end
  end

  describe '#run' do
    let(:cmd) { 'cmd1' }
    let(:env) { ['VAR1=VALUE1'] }
    let!(:container) { class_spy(Construi::Container).as_stubbed_const }

    subject! { image.run(cmd, env) }

    it { expect(container).to have_received(:run).with(image, cmd, env) }
  end

  describe '.build' do
    let(:build_dir) { 'etc/docker' }
    let!(:docker_image_class) { class_double(Docker::Image).as_stubbed_const }

    before do
      allow(docker_image_class)
        .to receive(:build_from_dir)
        .with(build_dir, :rm => 0)
        .and_yield('{"stream":"msg1"}')
        .and_yield('{"stream":"msg2"}')
        .and_return docker_image
    end

    subject! { Construi::Image.build(build_dir) }

    it {
      expect(docker_image_class)
         .to have_received(:build_from_dir).with(build_dir, :rm => 0)
    }

    it { expect(docker_image).to have_received(:refresh!) }

    it 'outputs building message' do
      building_msg = "Building image: 'etc/docker'...".green
      expect($stdout.string).to include("\n#{building_msg}\n")
    end

    it 'outputs build status messages' do
      expect($stdout.string).to include("msg1\nmsg2\n")
    end
  end

  describe '.create' do
    let(:image_tag) { 'tagged:latest' }
    let!(:docker_image_class) { class_double(Docker::Image).as_stubbed_const }

    before do
      allow(docker_image_class)
        .to receive(:create)
        .with('fromImage' => image_tag)
        .and_yield('{"id":"id","status":"msg1"}')
        .and_yield('{"id":"id","status":"msg2","progressDetail":{}}')
        .and_yield('{"id":"id","status":"msg3","progressDetail":{"progress":"====>"}}')
        .and_yield('{"status":"msg4"}')
        .and_return docker_image
    end

    subject! { Construi::Image.create(image_tag) }

    it { expect(docker_image_class).to have_received(:create).with('fromImage' => image_tag) }
    it { expect(docker_image).to have_received(:refresh!) }

    it 'outputs creating message' do
      creating_msg = "Creating image: 'tagged:latest'...".green
      expect($stdout.string).to include("\n#{creating_msg}\n")
    end

    it 'outputs create status messages' do
      expect($stdout.string).to include("id: msg1\nid: msg2\nmsg4\n")
    end
  end
end

RSpec.describe Construi::IntermediateImage do
  let(:image) { instance_double(Construi::Image).as_null_object }
  let(:second_image) { instance_double(Construi::Image).as_null_object }

  before do
    allow(image)
      .to receive(:run)
      .and_return image
  end

  before { allow(image).to receive(:run).and_return second_image }
  before do
    [image, second_image].each do |i|
      allow(i).to receive(:tagged?).and_return false
    end
  end

  subject(:intermediate_image) { Construi::IntermediateImage.seed(image) }

  describe '#run' do
    let(:cmd) { 'cmd1' }
    let(:env) { ['VAR1=VALUE1'] }

    context "single run" do
      subject! { intermediate_image.run(cmd, env) }

      it { expect(image).to have_received(:run).with(cmd, env) }
      it { expect(image).to_not have_received(:delete) }
      it { expect(second_image).to_not have_received(:delete) }
    end

    context "double run" do
      subject! { intermediate_image.run(cmd, env).run(cmd, env) }

      it { expect(second_image).to have_received(:run).with(cmd, env) }
      it { expect(second_image).to have_received(:delete) }
    end
  end



end

