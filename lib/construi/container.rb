require 'construi/image'

module Construi

  class Container
    private_class_method :new

    def initialize(container)
      @container = container
      @stdout_attached = false
    end

    def id
      @container.id
    end

    def start
      @container.start
      attach_stdout
    end

    def stop
      @container.stop
      @stdout_attached = false
    end

    def delete
      stop
      @container.kill
      @container.delete force: true, v: true
    end

    def attach_stdout
      @container.attach(:stream => true, :logs => true) { |s, c| puts c; $stdout.flush }
      @stdout_attached = true
    rescue Docker::Error::TimeoutError
      puts 'Failed to attach to stdout'.yellow
    end

    def stdout_attached?
      @stdout_attached
    end

    def commit
      Image.wrap(@container.commit)
    end

    def run
      start
      status_code = @container.wait['StatusCode']

      puts @container.logs(:stdout => true) unless stdout_attached?

      raise Error, "Cmd returned status code: #{status_code}" unless status_code == 0

      commit
    end

    def ==(other)
      other.is_a? Container and id == other.id
    end

    def self.create(image, cmd, options = {})
      env = options[:env] || []
      privileged = options[:privileged] || false

      host_config = {
        'Binds' => ["#{Dir.pwd}:/var/workspace"],
        'Privileged' => privileged
      }

      wrap Docker::Container.create(
        'Cmd' => cmd.split,
        'Image' => image.id,
        'Env' => env,
        'Tty' => false,
        'WorkingDir' => '/var/workspace',
        'HostConfig' => host_config)
    end

    def self.wrap(container)
      new container
    end

    def self.use(image, cmd, options = {})
      container = create image, cmd, options
      yield container
    ensure
      container.delete unless container.nil?
    end

    def self.run(image, cmd, options = {})
      use image, cmd, options, &:run
    end

    class Error < StandardError
    end

  end

end
