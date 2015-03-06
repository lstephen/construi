
module Construi

  class Config
    private_class_method :new

    attr_reader :yaml

    def initialize(yaml)
      @yaml = yaml
    end

    def self.load(path)
      new(YAML.load_file(path))
    end

    def image
      @yaml['image']
    end

    def env
      @yaml['environment'].reduce([]) do |acc, e|
        key = e.partition('=').first
        value = e.partition('=').last

        value = ENV[key] if value.empty?

        acc << "#{key}=#{value}" unless value.nil? or value.empty?
        acc
      end
    end

    def target(target)
      Target.new(@yaml['targets'][target])
    end
  end

  class Target
    def initialize(yaml)
      @yaml = yaml
    end

    def commands
      @yaml
    end
  end

end
