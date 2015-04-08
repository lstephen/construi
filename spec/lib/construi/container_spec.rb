require 'spec_helper'

require 'securerandom'

RSpec.describe Construi::Container do
  let!(:docker_container_class) { class_spy(Docker::Container).as_stubbed_const }
  let(:docker_container) do
    instance_double(Docker::Container, :id => SecureRandom.hex(16)).as_null_object
  end

  let(:image_id) { SecureRandom.hex(16) }
  let(:image) { instance_double(Docker::Image, :id => image_id).as_null_object }

  let(:container) { Construi::Container.wrap docker_container }

  describe '#delete' do
    subject! { container.delete }

    it { expect(docker_container).to have_received(:delete) }
  end

  describe '#attach_stdout' do
    subject(:attach_stdout) { -> { container.attach_stdout } }

    context 'when attached succesfully' do
      before do
        allow(docker_container)
          .to receive(:attach)
          .and_yield('stream', 'msg1')
          .and_yield('stream', 'msg2')
      end

      subject! { attach_stdout.call }

      it { expect(docker_container).to have_received(:attach).with(:stream => true, :logs => true) }
      it { expect($stdout.string).to include("msg1\nmsg2") }
    end

    context 'when attach times out' do
      before do
        allow(docker_container)
          .to receive(:attach)
          .and_raise(Docker::Error::TimeoutError.new)
      end

      subject! { attach_stdout.call }

      it { expect($stdout.string).to include('Failed to attach to stdout'.yellow) }
    end
  end

  describe '#commit' do
    before { allow(docker_container).to receive(:commit).and_return image }

    subject! { container.commit }

    it { expect(docker_container).to have_received(:commit) }
    it { is_expected.to eq(Construi::Image.wrap(image)) }
  end

  describe '#run' do
    before { allow(docker_container).to receive(:wait).and_return({'StatusCode' => status_code}) }
    before { allow(docker_container).to receive(:commit).and_return image }

    subject(:run) { -> { container.run } }

    context 'when command succeeds' do
      let(:status_code) { 0 }

      subject! { run.call }

      it { expect(docker_container).to have_received(:start) }
      it { expect(docker_container).to have_received(:attach).with(:stream => true, :logs => true) }
      it { expect(docker_container).to have_received(:wait) }
      it { expect(docker_container).to have_received(:commit) }
      it { is_expected.to eq(Construi::Image.wrap(image)) }
    end

    context 'when command fails' do
      let(:status_code) { 1 }

      it { expect { run.call }.to raise_error Construi::RunError,  /status code: 1/}
    end
  end

  describe '.create' do
    let(:cmd) { 'cmd1 p1 p2' }
    let(:env) { ['ENV1=VAL1', 'ENV2=VAL2'] }
    let(:pwd) { '/project/dir' }

    before { allow(docker_container_class).to receive(:create).and_return docker_container }
    before { allow(Dir).to receive(:pwd).and_return(pwd) }

    subject! { Construi::Container::create(image, cmd, env) }

    it do
      expect(docker_container_class).to have_received(:create).with( {
        'Cmd' => ['cmd1', 'p1', 'p2' ],
        'Image' => image_id,
        'Env' => env.to_json,
        'Tty' => false,
        'WorkingDir' => '/var/workspace',
        'HostConfig' => { 'Binds' => ["#{pwd}:/var/workspace"] }
        } )
    end
    it { is_expected.to eq(Construi::Container.wrap docker_container) }
  end

  describe '.run' do
    let(:cmd) { 'cmd1 p1 p2' }

    before { allow(docker_container_class).to receive(:create).and_return docker_container }
    before { allow(docker_container).to receive(:wait).and_return({'StatusCode' => 0}) }
    before { allow(docker_container).to receive(:commit).and_return image }

    subject! { Construi::Container.run(image, cmd, []) }

    it do
      expect(docker_container_class).to have_received(:create).with(
        hash_including( {
          'Cmd' => ['cmd1', 'p1', 'p2'],
          'Image' => image_id
        }))
    end
    it { is_expected.to eq(Construi::Image.wrap image) }
    it { expect(docker_container).to have_received(:start) }
    it { expect(docker_container).to have_received(:commit) }
    it { expect(docker_container).to have_received(:delete) }
  end

end

