require 'construi/image'

module Construi

  class Container
    private_class_method :new

    def initialize(container)
      @container = container
    end

    def delete
      @container.delete
    end

    def attach_stdout
      @container
        .tap(&:start)
        .attach(:stream => true, :logs => true) { |s, c| puts c; $stdout.flush }
    end

    def commit
      Image.wrap(@container.commit)
    end

    def run
      attach_stdout

      @container.start
      status_code = @container.wait['StatusCode']

      raise RunError 'Cmd returned status code: #{status_code}' unless status_code == 0

      commit
    end

    def self.create(image, cmd, env)
      wrap Docker::Container.create(
        'Cmd' => ["sh", "-c", cmd],
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
