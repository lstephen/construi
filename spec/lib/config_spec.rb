require 'spec_helper'

require 'construi/config'

RSpec.describe Construi::Config do
  let(:config_content) { '' }
  let(:config) { Construi::Config.load(config_content) }

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

  describe '#env' do
    subject { config.env }

    context 'when no environment' do
      it { is_expected.to eq([]) }
    end
  end

end

