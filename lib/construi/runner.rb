
require 'construi/container'
require 'construi/image'

require 'construi/version'

require 'colorize'
require 'docker'

module Construi

  class Runner
    def initialize(config)
      @config = config
    end

    def run(targets)
      puts "Construi version: #{Construi::VERSION}"

      docker_host = ENV['DOCKER_HOST']
      Docker.url = docker_host unless docker_host.nil?

      puts "Docker url: #{Docker.url}"
      puts "Current directory: #{Dir.pwd}"

      Docker.validate_version!
      Docker.options[:read_timeout] = 60
      Docker.options[:chunk_size] = 8

      targets.each do |t|
        puts "Running #{t}...".green

        commands = @config.target(t).commands

        final_image = commands.reduce(IntermediateImage.seed(initial_image(@config.target(t)))) do |image, command|
          puts
          puts " > #{command}".green
          image.run(command, @config.env)
        end

        final_image.delete
      end
    end

    def initial_image(target)
      return Image.create(target.image) unless target.image.nil?
      return Image.build(target.build) unless target.build.nil?

      raise "'build' or 'image' not set"
    end
  end

end

