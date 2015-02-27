require 'construi/config'
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

      final = @config.target(target).commands.reduce(image) { |i, c| run_cmd(i, c) }

      final.delete unless final.tagged?
    end

    def run_cmd(image, cmd)
      container = Docker::Container.create(
        'Cmd' => cmd.split,
        'Image' => image.id,
        'Tty' => false,
        'WorkingDir' => '/var/workspace',
        'HostConfig' => { 'Binds' => ["#{Dir.pwd}:/var/workspace"] })

      container.tap(&:start).attach(:stream => true, :logs => true) { |s, c| puts c; $stdout.flush }

      container.start

      container.wait

      image.delete unless image.tagged?

      image = Image.wrap(container.commit)

      #TODO: Delete intermediate images

      container.delete

      image
    end
  end

  def self.run
    Runner.new(Config.load('construi.yml')).run('build')
  end

end
