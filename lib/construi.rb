require 'docker'
require 'yaml'

module Construi

  def self.run
    Docker.validate_version!
    Docker.options[:read_timeout] = 60
    Docker.options[:chunk_size] = 8

    config = YAML.load_file('construi.yml')

    puts config
    puts Dir.pwd

    image = Docker::Image.create('fromImage' => config['image'])

    config['targets']['build'].each do |cmd|
      puts cmd

      container = Docker::Container.create(
        'Cmd' => cmd.split,
        'Image' => image.id, 
        'Tty' => false,
        'WorkingDir' => '/var/workspace',
        'HostConfig' => { 'Binds' => ["#{Dir.pwd}:/var/workspace"] })

      container.tap(&:start).attach(:stream => true, :logs => true) { |s, c| puts c; $stdout.flush }

      container.start

      container.wait

      image = container.commit

      #TODO: Delete intermediate images

      container.delete
    end

  end

end
