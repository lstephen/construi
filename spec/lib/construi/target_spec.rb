require 'spec_helper'

RSpec.describe Construi::Target do
  let(:parent_config) { Construi::Config.load('{}') }
  let(:target_config) do
    cfg = {}
    cfg['image'] = image unless image.nil?
    cfg['build'] = build unless build.nil?

    Construi::Config::Target.new(cfg, parent_config)
  end

  subject(:target) { Construi::Target.new nil, target_config }
end
