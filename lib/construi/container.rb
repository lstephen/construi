require 'construi/image'

module Construi
  class Container
    private_class_method :new

    attr_reader :name

    def initialize(container, options = {})
      @container = container
      @name = options[:name] || @container.id
      @log_lifecycle = options[:log_lifecycle] || false
    end

    def id
      @container.id
    end

    def start
      log_lifecycle "Starting container: '#{name}'..."
      @container.start!
      attach_stdout
    end

    def stop
      log_lifecycle "Stopping container: '#{name}'..."
      @container.stop
    end

    def delete
      stop
      @container.kill
      @container.delete force: true, v: true
      log_lifecycle "Deleted container: '#{name}'"
    end

    def attach_stdout
      Thread.new do
        @container.attach(:stream => true, :logs => true) { |_, c| Console.output name, c }
      end
    end

    def log_lifecycle?
      @log_lifecycle
    end

    def log_lifecycle(msg)
      Console.progress msg if log_lifecycle?
    end

    def commit
      Image.wrap(@container.commit)
    end

    def run
      start
      status_code = @container.wait['StatusCode']

      raise RunError, "Cmd returned status code: #{status_code}" unless status_code == 0

      commit
    end

    def ==(other)
      other.is_a? Container and id == other.id
    end

    def self.create(image, options = {})
      env = options[:env] || []
      privileged = options[:privileged] || false
      links = options[:links] || []
      volumes = options[:volumes] || []
      volumes_from = options[:volumes_from] || []

      host_config = {
        'Binds' => ["#{Dir.pwd}:/var/workspace"].concat(volumes),
        'Privileged' => privileged,
        'Links' => links,
        'VolumesFrom' => volumes_from
      }

      create_options = {
        'Image' => image.id,
        'Env' => env,
        'Tty' => false,
        'WorkingDir' => '/var/workspace',
        'HostConfig' => host_config
      }

      create_options['Cmd'] = options[:cmd].split if options.key?(:cmd)

      wrap Docker::Container.create(create_options), options
    end

    def self.wrap(container, options = {})
      new container, options
    end

    def self.use(image, options = {})
      container = create image, options
      yield container
    ensure
      container.delete unless container.nil?
    end

    def self.run(image, options = {})
      use image, options, &:run
    end

    class RunError < StandardError
    end

  end


end
