require 'construi/console'

module Construi
  class Target
    attr_reader :name, :config

    def initialize(name, config)
      @name = name
      @config = config
    end

    def commands
      @config.commands
    end

    def run
      Console.progress "Running #{name}..."

      links = start_linked_images

      begin
        final_image = IntermediateImage.seed(create_initial_image).reduce(commands) do |image, command|
          Console.progress " > #{command}"

          link_option = links.each_with_object([]) do |l, o|
            o << "#{l.id}:#{l.name}"
          end

          Construi.with_no_docker_timeout do
            image.run command, @config.options.merge(links: link_option)
          end
        end

        final_image.delete
      ensure
        links.map(&:delete)
      end

      Console.progress "Build Successful."
    end

    def create_initial_image
      return Image.from(@config)
    end

    def start_linked_images
      @config.links.map do |(name, config)|
        Image.from(config).start(config.options.merge name: name, log_lifecycle: true)
      end
    end
  end

end

