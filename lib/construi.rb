
require 'yaml'

module Construi
  require 'construi/config'
  require 'construi/runner'


  String.disable_colorization = false

  def self.run(targets)
    Runner.new(Config.load_file('construi.yml')).run(targets)
  end
end

