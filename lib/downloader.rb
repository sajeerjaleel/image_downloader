require_relative '../lib/downloader/batch_downloader'
require_relative 'configuration'

config = Configuration.new

file_path = config.file_path
concurrency = config.concurrency
images_folder = config.images_folder

batch_downloader = BatchDownloader.new(file_path, images_folder, concurrency)
batch_downloader.download
