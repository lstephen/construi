
module Construi
  module Console
    $stdout.sync = true

    def self.warn(msg)
      puts msg.yellow
    end

    def self.info(msg)
      puts msg.green
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

  end
end

