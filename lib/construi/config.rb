
module Construi::Config

  module Image
    def image
      return with_parent(&:image) unless yaml.is_a? Hash

      yaml['image'] || with_parent(&:image) unless yaml.has_key? 'build'
    end

    def build
      return with_parent(&:build) unless yaml.is_a? Hash

      yaml['build'] || with_parent(&:build) unless yaml.has_key? 'image'
    end
  end

  module Files
    File = Struct.new :host, :container, :permissions

    def files
      return with_parent(&:files) unless yaml.is_a? Hash and yaml.has_key? 'files'

      fs = yaml['files'].map do |str|
        split = str.split(':')
        File.new split[0], split[1], split[2]
      end

      Array(with_parent(&:files)).concat fs
    end
  end

  module Environment
    include Image
    include Files

    def parent
      nil
    end

    def with_parent
      parent ? yield(parent) : nil
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

  def self.load(content)
    Global.new YAML.load(content)
  end

  def self.load_file(path)
    Global.new YAML.load_file(path)
  end
end

