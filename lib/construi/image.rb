
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

    def self.create(image)
      wrap Docker::Image.create('fromImage' => image)
    end

    def self.wrap(image)
      new image
    end
  end

end
