require 'open-uri'
require 'fileutils'
require 'logger'
require 'securerandom'

class ImageDownloader
  attr_reader :url, :images_folder, :logger

  def initialize(url, images_folder, logger = Logger.new(STDOUT))
    @url = url
    @images_folder = images_folder
    @logger = logger
  end

  def download
    create_directory_unless_exists
    save_image_to_destination
    logger.info "Downloaded #{original_file_name}"
  rescue OpenURI::HTTPError => e
    logger.error "Failed to download #{url}: #{e.message}"
  rescue Errno::EACCES => e
    logger.error "Permission denied while writing to #{images_folder}: #{e.message}"
    raise e
  rescue => e
    logger.error "An error occurred while downloading #{url}: #{e.message}"
  end

  private

  def create_directory_unless_exists
    FileUtils.mkdir_p(images_folder)
  end

  def original_file_name
    File.basename(URI.parse(url).path)
  end

  def unique_file_name
    base_name, extension = original_file_name.split('.', 2)
    unique_suffix = SecureRandom.hex(8)
    "#{base_name}_#{unique_suffix}.#{extension}"
  end

  def destination_path
    File.join(images_folder, unique_file_name)
  end

  def save_image_to_destination
    URI.open(url) do |image|
      File.open(destination_path, 'wb') do |file|
        file.write(image.read)
      end
    end
  end
end
