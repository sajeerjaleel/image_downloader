require 'open-uri'
require 'fileutils'
require 'logger'

class ImageDownloader

  attr_reader :url, :images_folder, :logger

  def initialize(url, images_folder, logger = Logger.new(STDOUT))
    @url = url
    @images_folder = images_folder
    @logger = logger
  end

  def download
    file_name = File.basename(URI.parse(url).path)
    destination_path = File.join(images_folder, file_name)

    URI.open(url) do |image|
      File.open(destination_path, 'wb') do |file|
        file.write(image.read)
      end
    end

    logger.info "Downloaded #{file_name}"
  rescue OpenURI::HTTPError => e
    logger.error "Failed to download #{url}: #{e.message}"
  rescue Errno::EACCES => e
    logger.error "Permission denied while writing to #{images_folder}: #{e.message}"
    raise e
  rescue => e
    logger.error "An error occurred while downloading #{url}: #{e.message}"
  end
end