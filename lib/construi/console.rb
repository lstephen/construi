require 'construi/options'

module Construi
  module Console
    $stdout.sync = true

    def self.warn(msg)
      puts msg.yellow
    end

    def self.info(msg)
      puts msg.green
    end

    def self.verbose(msg)
      puts msg if Options.enabled?(:verbose)
    end

    def self.progress(msg)
      puts
      info msg
    end

    def self.output(from, msg)
      msg.each_line do |m|
        puts "#{from.rjust(13)} | ".blue << m
      end
    end

    def self.logger(name)
      Logger.new name
    end

    class Logger
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def debug?
        true
      end

      def debug(msg)
        Console.verbose "#{name}: #{msg}"
      end
    end
  end
end

