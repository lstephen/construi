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

    def run(cmd)
      Container.run(self, cmd)
    end

    def self.create(image)
      wrap Docker::Image.create('fromImage' => image)
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
    end

    def run(cmd)
      map { |i| i.run(cmd) }
    end

    def map
      update(yield @image)
    end

    def update(image)
      @image.delete unless @image.tagged?
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
