require_relative '../lib/downloader/batch_downloader'
require_relative 'configuration'
require_relative '../lib/logger/custom_logger'

config = Configuration.new

file_path = config.file_path
concurrency = config.concurrency
images_folder = config.images_folder
logger = CustomLogger.new(config.log_file)

batch_downloader = BatchDownloader.new(file_path, images_folder, concurrency, logger)
batch_downloader.download
