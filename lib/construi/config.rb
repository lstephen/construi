
require 'construi/target'

module Construi

  class Config
    private_class_method :new

    attr_reader :yaml

    def initialize(yaml)
      @yaml = yaml || {}
    end

    def self.load(content)
      new YAML.load(content)
    end

    def self.load_file(path)
      new YAML.load_file(path)
    end

    def image_config
      ImageConfig.load(@yaml)
    end

    def env
      return [] if @yaml['environment'].nil?

      @yaml['environment'].reduce([]) do |acc, e|
        key = e.partition('=').first
        value = e.partition('=').last

        value = ENV[key] if value.empty?

        acc << "#{key}=#{value}" unless value.nil? or value.empty?
        acc
      end
    end

    def target(target)
      targets = @yaml['targets']

      return nil if targets.nil?

      Target.new(target, @yaml['targets'][target], self)
    end
  end

  ImageConfig = Struct.new(:image, :build) do
    def self.load(yaml)
      return nil unless yaml.is_a?(Hash)

      image = yaml['image']
      build = yaml['build']

      return nil if image.nil? and build.nil?

      new image, build
    end
  end

end
