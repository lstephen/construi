require 'spec_helper'

RSpec.describe Construi do
  describe 'run' do
    let(:targets) { ['target1', 'target2'] }
    let(:config) { { 'image' => 'image:latest' } }

    let(:runner) { instance_double(Construi::Runner).as_null_object }
    let(:runner_class) { class_double(Construi::Runner).as_stubbed_const }

    before { allow(Construi::Config).to receive(:load_file).with('construi.yml').and_return(config) }
    before { allow(runner_class).to receive(:new).with(config).and_return runner }

    subject! { Construi.run(targets) }

    it { expect(runner_class).to have_received(:new).with(config) }
    it { expect(runner).to have_received(:run).with(targets) }
  end
end

