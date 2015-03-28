require 'construi/config'
require 'construi/container'
require 'construi/image'
require 'construi/version'

require 'colorize'
require 'docker'
require 'yaml'

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

      commands = targets.map { |t| @config.target(t).commands }.flatten

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

      raise "'build' or 'image' not set"
    end
  end

  def self.run(targets)
    Runner.new(Config.load_file('construi.yml')).run(targets)
  end

end
