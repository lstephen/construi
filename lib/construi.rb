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

    def run(target)
      Docker.validate_version!
      Docker.options[:read_timeout] = 60
      Docker.options[:chunk_size] = 8

      puts Dir.pwd

      image = Image.create(@config.image)

      final = @config.target(target).commands.reduce(image) do |i, c|
        begin
          run_cmd(i, c)
        ensure
          i.delete unless image.tagged?
        end
      end

      final.delete unless final.tagged?
    end

    def run_cmd(image, cmd)
      Container.create(image, cmd).run
    end
  end

  def self.run
    Runner.new(Config.load('construi.yml')).run('build')
  end

end
