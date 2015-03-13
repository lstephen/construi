require 'spec_helper'

require 'construi/config'

RSpec.describe Construi::Config do

  describe '#image' do
    let (:config_content) do
      <<-YAML
      image: #{image}
      YAML
    end

    let(:config) { Construi::Config.load(config_content) }

    subject { config.image }

    %w{ test-image:latest lstephen/construi:latest }.each do |image_name|
      context "when image is #{image_name}" do
        let(:image) { image_name }
        it { is_expected.to eq(image) }
      end
    end
  end

end

