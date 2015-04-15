
module Construi::Config

  module Image
    def image
      configured :image
    end

    def build
      configured :build
    end

    def configured?
      yaml.is_a?(Hash) && (yaml.has_key?('build') || yaml.has_key?('image'))
    end

    def configured(what)
      configured? ? yaml[what.to_s] : with_parent(&what)
    end
  end

  module Files

    class File
      attr_reader :container, :permissions

      def initialize(host, container, permissions)
        @host = host
        @container = container
        @permissions = permissions
      end

      def host
        @host.gsub(/\$(\w+)/) { ENV[$1] }
      end
    end

    def files
      return with_parent([], &:files) unless yaml.is_a? Hash and yaml.has_key? 'files'

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

    def with_parent(or_else = nil)
      parent ? yield(parent) : or_else
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

