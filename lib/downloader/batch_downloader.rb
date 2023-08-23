require 'concurrent'
require 'logger'
require_relative '../downloader/url_reader'
require_relative '../downloader/image_downloader'

class BatchDownloader

  attr_reader :file_path, :images_folder, :thread_pool, :logger

  def initialize(file_path, images_folder, concurrency, logger = Logger.new(STDOUT))
    @file_path = file_path
    @images_folder = File.expand_path("../../../#{images_folder}", __FILE__)
    @logger = logger

    begin
      FileUtils.mkdir_p(images_folder) unless Dir.exist?(images_folder)
    rescue Errno::EACCES => e
      logger.error "Permission denied while creating images folder: #{e.message}"
      raise e
    end
    @thread_pool = Concurrent::FixedThreadPool.new(concurrency)
  end

  def download
    begin
      reader = URLReader.new(file_path)
      reader.each_valid_url do |url|
        thread_pool.post do
          begin
            downloader = ImageDownloader.new(url, images_folder, logger)
            downloader.download
          rescue => e
            logger.error "An error occurred while downloading #{url}: #{e.message}"
          end
        end
      end

      # Shut down the thread pool
      thread_pool.shutdown
      thread_pool.wait_for_termination
      logger.info "Download complete!"
    rescue => e
      logger.error "An unexpected error occurred: #{e.message}"
    end
  end
end
