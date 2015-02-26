require 'construi/config'

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

      config = Config.load('construi.yml')

      puts Dir.pwd

      image = Docker::Image.create('fromImage' => config.image)

      final = config.target(target).commands.reduce(image) { |i, c| run_cmd(i, c) }

      puts final.refresh!
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

      puts image.refresh!

      image = container.commit

      #TODO: Delete intermediate images

      container.delete

      image
    end
  end

  def self.run
    Runner.new(Config.load('construi.yml')).run('build')
  end

end
