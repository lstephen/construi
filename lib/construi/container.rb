require 'construi/image'

module Construi

  class Container
    private_class_method :new

    def initialize(options)
      @options = options
    end

    def use
      container = Docker::Container.create(@options)
      yield container
    ensure
      container.delete unless container.nil?
    end

    def run
      use do |container|
        container
          .tap(&:start)
          .attach(:stream => true, :logs => true) { |s, c| puts c; $stdout.flush }

        container.start
        status_code = container.wait['StatusCode']

        raise RunError 'Cmd returned status code: #{status_code}' unless status_code == 0

        Image.wrap(container.commit)
      end
    end

    def self.create(image, cmd)
      new 'Cmd' => cmd.split,
          'Image' => image.id,
          'Tty' => false,
          'WorkingDir' => '/var/workspace',
          'HostConfig' => { 'Binds' => ["#{Dir.pwd}:/var/workspace"] }
    end

  end

  class ContainerError < StandardError
  end

  class RunError < ContainerError
  end


end
