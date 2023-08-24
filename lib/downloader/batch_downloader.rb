require 'concurrent'
require 'logger'
require_relative '../downloader/url_reader'
require_relative '../downloader/image_downloader'

class BatchDownloader

  attr_reader :file_path, :images_folder, :thread_pool, :logger, :reader_class, :downloader_class

  def initialize(file_path, images_folder, concurrency, logger = Logger.new(STDOUT), reader_class: URLReader, downloader_class: ImageDownloader, thread_pool_class: Concurrent::FixedThreadPool)
    @file_path = file_path
    @images_folder = File.expand_path("../../../#{images_folder}", __FILE__)
    @logger = logger
    @reader_class = reader_class
    @downloader_class = downloader_class
    @thread_pool = thread_pool_class.new(concurrency)
    setup_folder
  end

  def download
    begin
      reader = reader_class.new(file_path, logger)
      reader.each_valid_url do |url|
        thread_pool.post do
          download_url(url)
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

  private

  def setup_folder
    begin
      FileUtils.mkdir_p(images_folder) unless Dir.exist?(images_folder)
    rescue Errno::EACCES, Errno::EROFS => e
      logger.error "Permission denied while creating images folder: #{e.message}"
      raise e
    end
  end

  def download_url(url)
    begin
      downloader = downloader_class.new(url, images_folder, logger)
      downloader.download
    rescue => e
      logger.error "An error occurred while downloading #{url}: #{e.message}"
    end
  end

end
