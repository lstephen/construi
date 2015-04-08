require 'construi/image'

module Construi

  class Container
    private_class_method :new

    def initialize(container)
      @container = container
    end

    def id
      @container.id
    end

    def delete
      @container.delete
    end

    def attach_stdout
      @container.attach(:stream => true, :logs => true) { |s, c| puts c; $stdout.flush }
    rescue Docker::Error::TimeoutError
      puts 'Failed to attach to stdout'.yellow
    end

    def commit
      Image.wrap(@container.commit)
    end

    def run
      @container.start
      attach_stdout
      status_code = @container.wait['StatusCode']

      raise RunError.new 'Cmd returned status code: #{status_code}' unless status_code == 0

      commit
    end

    def ==(other)
      other.is_a? Container and id == other.id
    end

    def self.create(image, cmd, env)
      wrap Docker::Container.create(
        'Cmd' => cmd.split,
        'Image' => image.id,
        'Env' => env.to_json,
        'Tty' => false,
        'WorkingDir' => '/var/workspace',
        'HostConfig' => { 'Binds' => ["#{Dir.pwd}:/var/workspace"] })
    end

    def self.wrap(container)
      new container
    end

    def self.use(image, cmd, env)
      container = create(image, cmd, env)
      yield container
    ensure
      container.delete unless container.nil?
    end

    def self.run(image, cmd, env)
      use(image, cmd, env, &:run)
    end

  end

  class ContainerError < StandardError
  end

  class RunError < ContainerError
  end

end
