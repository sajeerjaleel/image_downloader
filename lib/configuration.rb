require 'yaml'

class Configuration

  attr_reader :file_path, :images_folder, :concurrency, :log_file

  def initialize(yml_path = "../../config/config.yml")
    begin
      config_file_path = File.expand_path("#{yml_path}", __FILE__)
      config = YAML.load_file(config_file_path)

      @file_path = config['file_path']
      @images_folder = config['images_folder']
      @concurrency = config['concurrency'].to_i
      @log_file = config['log_file']
    rescue Errno::ENOENT
      puts "Error: Configuration file #{yml_path} not found."
      exit
    rescue => e
      puts "Error reading configuration: #{e.message}"
      exit
    end
  end
end
