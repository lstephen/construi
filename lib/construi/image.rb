require 'construi/container'

require 'colorize'
require 'docker'

module Construi
  # A Docker Image
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

    def docker_image
      @image
    end

    def tagged?
      @image.info['RepoTags'] != '<none>:<none>'
    end

    def insert_local(file, options = {})
      puts "\nCopying #{file.host} to #{file.container}...".green

      img = IntermediateImage.seed(self)

      img.map do |i|
        Image.wrap i.docker_image
          .insert_local 'localPath' => file.host, 'outputPath' => file.container
      end

      img.map { |i| i.chmod file.container, file.permissions, options } if file.permissions

      img.run "ls -l #{file.container}", options

      img.image
    end

    def insert_locals(files, options = {})
      IntermediateImage
        .seed(self)
        .reduce(files) { |a, e| a.insert_local e, options }
        .image
    end

    def chmod(file, permissions, options = {})
      chmod = "chmod -R #{permissions} #{file}"

      puts " > #{chmod}"
      run chmod, options
    end

    def run(cmd, options = {})
      Container.run self, options.merge(cmd: cmd)
    end

    def ==(other)
      other.is_a?(Image) && id == other.id
    end

    def self.from(config)
      image = create(config.image) unless config.image.nil?
      image = build(config.build) unless config.build.nil?

      fail Error, "Invalid image configuration: #{config}" unless image

      image.insert_locals config.files, privileged: config.privileged?
    end

    def self.create(image)
      puts
      puts "Creating image: '#{image}'...".green
      wrap Docker::Image.create('fromImage' => image) { |s|
        status = JSON.parse(s)

        id = status['id']
        progress = status['progressDetail']

        if progress.nil? || progress.empty?
          print "#{id}: " unless id.nil?
          puts "#{status['status']}"
        end
      }
    end

    def self.build(build)
      puts
      puts "Building image: '#{build}'...".green
      wrap Docker::Image.build_from_dir(build, rm: 0) { |s|
        puts JSON.parse(s)['stream']
      }
    end

    def self.wrap(image)
      new image
    end

    class Error < StandardError
    end
  end

  # An image that represents an intermediatae state of an image.
  # Useful for performing operations where each opertion is performed on the
  # result of the last.
  class IntermediateImage
    private_class_method :new

    attr_reader :image

    def initialize(image)
      @image = image
      @first = true
    end

    def run(cmd, options = {})
      map { |i| i.run cmd, options }
    end

    def map
      update(yield @image)
    end

    def reduce(iter)
      iter.reduce(self) do |intermediate_image, item|
        intermediate_image.map { |i| yield i, item }
      end
    end

    def update(image)
      delete unless @first
      @first = false
      @image = image
      self
    end

    def delete
      @image.delete unless @image.tagged?
    end

    def self.seed(image)
      new image
    end
  end
end
