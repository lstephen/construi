

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

    def image_config
      @config.image_config
    end

    def run
      puts "Running #{name}...".green

      final_image = commands.reduce(IntermediateImage.seed(initial_image)) do |image, command|
        puts
        puts " > #{command}".green
        image.run(command, @config.env)
      end

      final_image.delete
    end

    def initial_image
      raise 'No image configured' if image_config.nil?

      return Image.create(image_config.image) unless image_config.image.nil?
      return Image.build(image_config.build) unless image_config.build.nil?
    end
  end

end

