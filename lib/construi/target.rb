

module Construi

  class Target
    attr_reader :name, :parent

    def initialize(name, yaml, parent)
      @name = name
      @yaml = yaml
      @parent = parent
    end

    def commands
      Array(@yaml.is_a?(Hash) ? @yaml['run'] : @yaml)
    end

    def image_config
      ImageConfig.load(@yaml) || @parent.image_config
    end

    def run
      puts "Running #{name}...".green

      final_image = commands.reduce(IntermediateImage.seed(initial_image)) do |image, command|
        puts
        puts " > #{command}".green
        image.run(command, parent.env)
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

