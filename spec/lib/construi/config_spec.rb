
require 'spec_helper'
require 'construi/config'

RSpec.describe Construi::Config do
  let(:config_content) { '' }
  let(:config) { Construi::Config.load(config_content) }

  describe '.load_file' do
    let(:config_file) { Tempfile.new('config.load_file') }
    let(:config_content) do
      <<-YAML
      image: test-image
      YAML
    end

    before do
      config_file.write(config_content)
      config_file.close
    end

    after do
      config_file.unlink
    end

    subject { Construi::Config.load_file(config_file) }

    it { is_expected.to_not be(nil) }
    it { expect(subject.image).to eq('test-image') }
  end

  describe '#image' do
    let(:config_content) do
      <<-YAML
      image: #{image}
      YAML
    end

    subject { config.image }

    %w{ test-image:latest lstephen/construi:latest }.each do |image_name|
      context "when image is #{image_name}" do
        let(:image) { image_name }
        it { is_expected.to eq(image) }
      end
    end
  end

  describe '#build' do
    let(:config_content) do
      <<-YAML
      build: #{build}
      YAML
    end

    subject { config.build }

    %w{ . construi/dev etc/docker/ }.each do |build|
      context "when build is #{build}" do
        let(:build) { build }
        it { is_expected.to eq(build) }
      end
    end
  end

  describe '#env' do
    subject { config.env }

    context 'when no environment section' do
      it { is_expected.to eq([]) }
    end

    context 'when explicitly set environment values' do
      let(:config_content) do
        <<-YAML
        environment:
          - VAR1=VALUE_1
          - VAR2=VALUE_2
        YAML
      end

      it { is_expected.to contain_exactly('VAR1=VALUE_1', 'VAR2=VALUE_2') }
    end

    context 'when passing through environment varaibles' do
      before do
        ENV['VAR1'] = 'VALUE_1'
        ENV['VAR2'] = 'VALUE_2'
      end

      let(:config_content) do
        <<-YAML
        environment:
          - VAR1
          - VAR2
        YAML
      end

      it { is_expected.to contain_exactly('VAR1=VALUE_1', 'VAR2=VALUE_2') }
    end
  end

  describe '#target' do
    let(:target) { 'build' }

    subject { config.target target }

    context 'when no target name' do
      let(:target) { nil }
      it { is_expected.to be(nil) }
    end

    context 'when no targets configured' do
      it { is_expected.to be(nil) }
    end

    context 'when targets configured' do
      let(:config_content) do
        <<-YAML
        targets:
          build:
            - cmd1
            - cmd2
          release:
            - cmd3
            - cmd4
        YAML
      end

      it { is_expected.to_not be(nil) }
      it { expect(subject.commands).to eq(['cmd1', 'cmd2']) }
    end

    context 'when single command' do
      let(:config_content) do
        <<-YAML
        targets:
          build: cmd1
        YAML
      end

      it { is_expected.to_not be(nil) }
      it { expect(subject.commands).to eq(['cmd1']) }
    end
    context 'when using run command' do
      let(:config_content) do
        <<-YAML
        targets:
          build:
            run:
              - cmd1
              - cmd2
        YAML
      end

      it { is_expected.to_not be(nil) }
      it { expect(subject.commands).to eq(['cmd1', 'cmd2']) }
    end

    context 'when using single run command' do
      let(:config_content) do
        <<-YAML
        targets:
          build:
            run: cmd1
        YAML
      end

      it { is_expected.to_not be(nil) }
      it { expect(subject.commands).to eq(['cmd1']) }
    end

    context 'when no image for target' do
      let(:config_content) do
        <<-YAML
        image: global:image
        targets:
          build: cmd1
          release:
            image: release:image
            run:
              - cmd3
              - cmd4
        YAML
      end

      it { expect(subject.image).to eq('global:image') }
    end

    context 'when image for target' do
      let(:config_content) do
        <<-YAML
        image: global:image
        targets:
          build:
            image: build:image
            run: cmd1
        YAML
      end

      it { expect(subject.image).to eq('build:image') }
    end

    context 'when build for target and image for global' do
      let(:config_content) do
        <<-YAML
        image: global:image
        targets:
          build:
            build: build/build
            run: cmd1
        YAML
      end

      it { expect(subject.image).to be(nil) }
      it { expect(subject.build).to eq('build/build') }
    end

  end
end

