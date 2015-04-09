

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
      puts "Running #{name}...".green

      final_image = commands.reduce(IntermediateImage.seed(initial_image)) do |image, command|
        puts
        puts " > #{command}".green
        image.run(command, @config.env)
      end

      final_image.delete
    end

    def initial_image
      return Image.create(@config.image) unless @config.image.nil?
      return Image.build(@config.build) unless @config.build.nil?
      raise 'No image configured'
    end
  end

end

