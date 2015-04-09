
require 'construi/container'
require 'construi/image'
require 'construi/target'

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

      targets.map {|t| Target.new t, @config.target(t) } .each(&:run)
    end

  end

end

