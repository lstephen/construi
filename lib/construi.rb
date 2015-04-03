require 'construi/config'
require 'construi/runner'

require 'yaml'

module Construi
  String.disable_colorization = false

  def self.run(targets)
    Runner.new(Config.load_file('construi.yml')).run(targets)
  end
end

