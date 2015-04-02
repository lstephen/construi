
require 'spec_helper'
require 'construi/image'

RSpec.describe Construi::Image do
  let(:image) { instance_double("Docker::Image").as_null_object }

  subject { Construi::Image.wrap(image) }

  describe '#id' do
    let(:id) { 'test_id' }

    it {
      allow(image).to receive(:id).and_return id
      expect(subject.id).to eq(id)
    }
  end

  describe '#delete' do
    it {
      expect(image).to receive(:delete)
      subject.delete
    }
  end

  describe '#tagged?' do
    before do
      allow(image).to receive(:info).and_return({ 'RepoTags' => tag })
    end

    context 'tagged' do
      let(:tag) { 'tagged:latest' }
      it { expect(subject.tagged?).to be(true) }
    end

    context 'not tagged' do
      let(:tag) { '<none>:<none>' }
      it { expect(subject.tagged?).to be(false) }
    end
  end

  describe '#run' do
    let(:cmd) { 'cmd1' }
    let(:env) { ['VAR1=VALUE1'] }

    it 'delegates to Container.run' do
      expect(class_double("Construi::Container").as_stubbed_const)
        .to receive(:run).with(subject, cmd, env)

      subject.run(cmd, env)
    end
  end

  describe '.build' do
    let(:build_dir) { 'etc/docker' }

    subject { -> { Construi::Image.build(build_dir) } }

    before do
      allow(Docker::Image).to receive(:build_from_dir).and_return image
    end

    it 'builds from the directory' do
      expect(class_double("Docker::Image").as_stubbed_const)
        .to receive(:build_from_dir).with(build_dir, :rm => 0) { image }

      subject.call
    end

    it do
      expect(image).to receive(:refresh!)
      subject.call
    end

    it 'outputs building message' do
      subject.call

      building_msg = "Building image: 'etc/docker'...".green
      expect($stdout.string).to eq("\n#{building_msg}\n")
    end

    it 'outputs build status messages' do
      allow(Docker::Image)
        .to receive(:build_from_dir)
        .and_return(image)
        .and_yield('{"stream":"msg1"}')
        .and_yield('{"stream":"msg2"}')

      subject.call

      expect($stdout.string).to include("msg1\nmsg2\n")
    end
  end

  describe '.create' do
    let(:image_tag) { 'tagged:latest' }

    subject { -> { Construi::Image.create(image_tag) } }

    before do
      allow(Docker::Image).to receive(:create).and_return image
    end

    it 'creates the tagged image' do
      expect(class_double("Docker::Image").as_stubbed_const)
        .to receive(:create).with('fromImage' => image_tag) { image }

      subject.call
    end

    it do
      expect(image).to receive(:refresh!)
      subject.call
    end

    it 'outputs creating message' do
      subject.call

      creating_msg = "Creating image: 'tagged:latest'...".green
      expect($stdout.string).to eq("\n#{creating_msg}\n")
    end

    it 'outputs create status messages' do
      allow(Docker::Image)
        .to receive(:create)
        .and_return(image)
        .and_yield('{"id":"id","status":"msg1"}')
        .and_yield('{"id":"id","status":"msg2","progressDetail":{}}')
        .and_yield('{"id":"id","status":"msg3","progressDetail":{"progress":"====>"}}')
        .and_yield('{"status":"msg4"}')

      subject.call

      expect($stdout.string).to include("id: msg1\nid: msg2\nmsg4\n")
    end
  end


end

