require 'construi/config'
require 'construi/container'
require 'construi/image'

require 'docker'
require 'yaml'

module Construi

  class Runner
    def initialize(config)
      @config = config
    end

    def run(targets)
      Docker.validate_version!
      Docker.options[:read_timeout] = 60
      Docker.options[:chunk_size] = 8

      initial_image = Image.create(@config.image)

      commands = targets.map { |t| @config.target(t).commands }.flatten

      final_image = commands.reduce(IntermediateImage.seed(initial_image)) do |image, command|
        image.run(command)
      end

      final_image.delete
    end
  end

  def self.run(targets)
    Runner.new(Config.load('construi.yml')).run(targets)
  end

end
