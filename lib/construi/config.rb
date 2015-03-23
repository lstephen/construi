
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

    def image
      @yaml['image']
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

      Target.new(@yaml['targets'][target])
    end
  end

  class Target
    def initialize(yaml)
      @yaml = yaml
    end

    def commands
      cmds = @yaml.is_a?(Hash) ? @yaml['run'] : @yaml

      Array(cmds)
    end
  end

end
