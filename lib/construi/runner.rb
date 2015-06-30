
require 'construi/container'
require 'construi/image'
require 'construi/target'

require 'construi/version'

require 'colorize'
require 'docker'

module Construi
  # Runs Construi
  class Runner
    def initialize(config)
      @config = config
    end

    def setup_docker
      docker_host = ENV['DOCKER_HOST']
      Docker.url = docker_host if docker_host

      puts "Docker url: #{Docker.url}"

      Excon.defaults[:ssl_verify_peer] = false

      Docker.validate_version!

      # Don't time out. We can't differentiate between a long running
      # task and a time out.
      Docker.options[:read_timeout] = nil

      # Low chunk size as we wish to receive streaming output ASAP
      Docker.options[:chunk_size] = 8
    end

    def run(targets)
      puts "Construi version: #{Construi::VERSION}"

      setup_docker

      puts "Current directory: #{Dir.pwd}"

      targets.map { |t| Target.new t, @config.target(t) } .each(&:run)
    end
  end
end
