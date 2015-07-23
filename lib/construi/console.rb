
module Construi
  module Console

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

  end
end

