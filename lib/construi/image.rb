require 'construi/container'

module Construi

  class Image
    private_class_method :new

    def initialize(image)
      @image = image.refresh!
    end

    def id
      @image.id
    end

    def delete
      @image.delete
    end

    def tagged?
      @image.info['RepoTags'] != '<none>:<none>'
    end

    def run(cmd, env)
      Container.run(self, cmd, env)
    end

    def self.create(image)
      puts
      puts "Creating image: '#{image}'...".green
      wrap Docker::Image.create('fromImage' => image) { |s|
        status = JSON.parse(s)

        id = status['id']
        progress = status['progressDetail']

        if progress.nil? or progress.empty?
          print "#{id}: " unless id.nil?
          puts "#{status['status']}" if progress.nil? or progress.empty?
        end
      }
    end

    def self.build(build)
      puts
      puts "Building image: '#{build}'...".green
      wrap Docker::Image.build_from_dir(build, :rm => 0) { |s|
        puts JSON.parse(s)['stream']
      }
    end

    def self.wrap(image)
      new image
    end

    def self.use(image)
      begin
        i = create(image)
        yield i
      ensure
        i.delete unless i.tagged?
      end
    end
  end

  class IntermediateImage
    private_class_method :new

    def initialize(image)
      @image = image
      @first = true
    end

    def run(cmd, env)
      map { |i| i.run(cmd, env) }
    end

    def map
      update(yield @image)
    end

    def update(image)
      @image.delete unless @first or @image.tagged?
      @first = false
      @image = image
    end

    def delete
      @image.delete unless @image.tagged?
    end

    def self.seed(image)
      new image
    end
  end
end
