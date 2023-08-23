require 'uri'
require 'logger'

class URLReader

  attr_reader :file_path, :logger

  def initialize(file_path, logger = Logger.new(STDOUT))
    @file_path = file_path
    @logger = logger

    raise Errno::ENOENT, "File not found: #{file_path}" unless File.exist?(file_path)
  end

  def each_valid_url
    File.foreach(file_path) do |line|
      urls = line.split
      urls.each do |url|
        if valid_image_url?(url)
          yield url
        else
          logger.warn "Invalid image URL: #{url}"
        end
      end
    end
  rescue => e
    logger.error "An unexpected error occurred while reading file: #{file_path}. Error: #{e.message}"
  end

  private

  def valid_image_url?(url)
    uri = URI.parse(url)
    (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.path =~ /\.(jpg|jpeg|png|gif|bmp)$/i
  rescue URI::InvalidURIError
    false
  end

end
