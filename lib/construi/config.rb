
module Construi::Config

  module Environment
    def parent
      nil
    end

    def image_config
      ImageConfig.load(yaml) || (parent.nil? ? nil : parent.image_config)
    end
  end

  class Global
    include Environment

    attr_reader :yaml

    def initialize(yaml)
      @yaml = yaml
    end

    def env
      return [] if yaml['environment'].nil?

      yaml['environment'].reduce([]) do |acc, e|
        key = e.partition('=').first
        value = e.partition('=').last

        value = ENV[key] if value.empty?

        acc << "#{key}=#{value}" unless value.nil? or value.empty?
        acc
      end
    end

    def target(target)
      targets = yaml['targets']

      return nil if targets.nil?

      return Target.new yaml['targets'][target], self
    end
  end

  class Target
    include Environment

    attr_reader :yaml, :parent

    def initialize(yaml, parent)
      @yaml = yaml
      @parent = parent
    end

    def commands
      Array(@yaml.is_a?(Hash) ? @yaml['run'] : @yaml)
    end

    def env
      parent.env
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

  def self.load(content)
    Global.new YAML.load(content)
  end

  def self.load_file(path)
    Global.new YAML.load_file(path)
  end
end

