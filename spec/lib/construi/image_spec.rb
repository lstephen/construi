
require 'spec_helper'

require 'securerandom'

RSpec.describe Construi::Image do
  let(:id) {  SecureRandom.hex(16) }

  let(:docker_image) do
    instance_double(Docker::Image, id: id).as_null_object
  end

  let!(:docker_image_class) { class_spy(Docker::Image).as_stubbed_const }
  let!(:container_class) { class_spy(Construi::Container).as_stubbed_const }

  let(:default_options) { {} }

  subject(:image) { Construi::Image.wrap(docker_image) }

  describe '#id' do
    subject { image.id }
    it { is_expected.to eq(id) }
  end

  describe '#delete' do
    subject! { image.delete }
    it { expect(docker_image).to have_received(:delete) }
  end

  describe '#tagged?' do
    before do
      allow(docker_image).to receive(:info).and_return('RepoTags' => tag)
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

    subject! { image.run(cmd, env: env) }

    it { expect(container).to have_received(:run).with(image, cmd: cmd, env: env) }
  end

  describe '#insert_local' do
    let(:host) { '/path/host' }
    let(:container) { '/path/on/container' }
    let(:permissions) { nil }

    let(:file) do
      Construi::Config::Files::File.new host, container, permissions
    end

    before do
      allow(docker_image).to receive(:info).and_return('RepoTags' => '<none>:<none>')
    end

    before { allow(docker_image).to receive(:insert_local).and_return(docker_image) }
    before { allow(container_class).to receive(:run).and_return image }

    subject! { image.insert_local file }

    context 'no permissions' do
      it { expect(subject.id).to eq(id) }
      it do
        expect(docker_image)
          .to have_received(:insert_local)
          .with 'localPath' => host, 'outputPath' => container
      end
      it { expect(container_class).to have_received(:run).with(image, default_options.merge(cmd: "ls -l #{container}")) }
    end

    context 'with permissions' do
      let(:permissions) { '0600' }

      it { expect(subject.id).to eq(id) }
      it do
        expect(docker_image)
          .to have_received(:insert_local)
          .with 'localPath' => host, 'outputPath' => container
      end
      it do
        expect(container_class)
          .to have_received(:run)
          .with(image, cmd: "chmod -R #{permissions} #{container}")
      end
      it { expect($stdout.string).to include(" > chmod -R #{permissions} #{container}") }
      it { expect(container_class).to have_received(:run).with(image, default_options.merge(cmd: "ls -l #{container}")) }
    end

  end

  describe '.from' do
    let(:config) { instance_double(Construi::Config::Environment).as_null_object }

    let(:image) { nil }
    let(:build) { nil }
    let(:files) { [] }
    let(:privileged?) { false }

    before { allow(config).to receive(:image).and_return image }
    before { allow(config).to receive(:build).and_return build }
    before { allow(config).to receive(:files).and_return files }
    before { allow(config).to receive(:privileged?).and_return privileged? }

    [:create, :build_from_dir].each do |m|
      before { allow(docker_image_class).to receive(m).and_return docker_image }
    end

    subject(:from) { -> { Construi::Image.from(config) } }

    context 'when build' do
      let(:build) { 'build/dir' }

      subject! { from.call }

      it { expect(docker_image_class).to have_received(:build_from_dir) }
    end

    context 'when image' do
      let(:image) { 'image:latest' }

      subject! { from.call }

      it { expect(docker_image_class).to have_received(:create) }
    end

    context 'when invalid' do
      it { expect { from.call }.to raise_error(Construi::Image::Error, /Invalid image configuration/) }
    end

    context 'when files' do
      let(:image) { 'image:latest' }
      before { allow(docker_image).to receive(:info).and_return({ 'RepoTags' => image }) }

      let(:host) { '/path/host' }
      let(:container) { '/path/on/container' }
      let(:permissions) { nil }

      let(:files) { [ Construi::Config::Files::File.new(host, container, permissions) ] }

      subject! { from.call }

      it { expect(docker_image_class).to have_received(:create) }
      it do
        expect(docker_image)
          .to have_received(:insert_local)
          .with 'localPath' => host, 'outputPath' => container
      end
      it { expect($stdout.string).to include("\nCopying #{host} to #{container}...".green) }
    end
  end

  describe '.build' do
    let(:build_dir) { 'etc/docker' }

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
    let(:options) { { env: ['VAR1=VALUE1']} }

    context "single run" do
      subject! { intermediate_image.run(cmd, options) }

      it { expect(image).to have_received(:run).with(cmd, options) }
      it { expect(image).to_not have_received(:delete) }
      it { expect(second_image).to_not have_received(:delete) }
    end

    context "double run" do
      subject! { intermediate_image.run(cmd, options).run(cmd, options) }

      it { expect(second_image).to have_received(:run).with(cmd, options) }
      it { expect(second_image).to have_received(:delete) }
    end
  end
end

