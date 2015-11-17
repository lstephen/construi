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

          options = config.options.merge(
            links: link_option(links),
            volumes_from: volumes_from_option(config, links),
            name: name
          )

          image.run command, options
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
        options = config.options.merge(
          name: name,
          log_lifecycle: true
        )

        Image.from(config).start options
      end
    end

    def link_option(links)
      links.each_with_object([]) do |l, o|
        o << "#{l.id}:#{l.name}"
      end
    end

    def volumes_from_option(config, links)
      config.volumes_from.each_with_object([]) do |v, o|
        volume_from = links.detect { |l| l.name == v }

        o << (volume_from.nil? ? v : volume_from.id)
      end
    end
  end

end

