require 'webmock/rspec'
require_relative '../lib/downloader/batch_downloader'

RSpec.describe 'End-to-End Image Downloading' do
  let!(:sample_file_path) { "spec/fixtures/sample_urls.txt" }
  let!(:test_images_folder) { "spec/fixtures/test_images" }
  let!(:concurrency) { 2 }
  let!(:logger) { Logger.new("/dev/null") }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
    FileUtils.mkdir_p(test_images_folder)
  end

  after do
    FileUtils.rm_rf(test_images_folder)
    File.delete(sample_file_path) if File.exist?(sample_file_path)
    WebMock.reset!
  end

  context 'when downloading images from valid URLs' do
    before do
      File.write(sample_file_path, "http://example.com/img1.jpg\nhttp://example.com/img2.jpg\nhttp://example.com/img3.jpg")

      stub_request(:get, "http://example.com/img1.jpg")
        .to_return(status: 200, body: "IMAGE_CONTENT_1")

      stub_request(:get, "http://example.com/img2.jpg")
        .to_return(status: 200, body: "IMAGE_CONTENT_2")

      stub_request(:get, "http://example.com/img3.jpg")
        .to_return(status: 200, body: "IMAGE_CONTENT_3")
    end

    it 'downloads images and stores them in the test folder' do
      batch_downloader = BatchDownloader.new(sample_file_path, test_images_folder, concurrency, logger)
      batch_downloader.download

      downloaded_files = Dir[File.join(test_images_folder, '*')]
      expect(downloaded_files.count).to eq(3)

      downloaded_files.each do |file|
        content = File.read(file)
        expect(["IMAGE_CONTENT_1", "IMAGE_CONTENT_2", "IMAGE_CONTENT_3"]).to include(content)
      end

      # Ensure that the filenames are unique
      downloaded_file_names = downloaded_files.map { |path| File.basename(path) }
      expect(downloaded_file_names.uniq.count).to eq(downloaded_file_names.count)
    end
  end

  context 'when the list contains invalid URLs' do
    before do
      File.write(sample_file_path, "http://invalid.url\nhttp://example.com/img1.jpg")

      stub_request(:get, "http://example.com/img1.jpg")
        .to_return(status: 200, body: "IMAGE_CONTENT_1")

      allow(logger).to receive(:warn)
      logger.level = Logger::WARN
    end

    it 'skips invalid URLs and logs a warning' do
      batch_downloader = BatchDownloader.new(sample_file_path, test_images_folder, concurrency, logger)
      batch_downloader.download

      expect(logger).to have_received(:warn).with("Invalid image URL: http://invalid.url")

      downloaded_files = Dir[File.join(test_images_folder, '*')]
      expect(downloaded_files.count).to eq(1)

      downloaded_files.each do |file|
        content = File.read(file)
        expect(["IMAGE_CONTENT_1"]).to include(content)
      end
    end
  end

  context 'when image URLs lead to 404s' do
    before do
      File.write(sample_file_path, "http://example.com/nonexistent.jpg\nhttp://example.com/img1.jpg")

      stub_request(:get, "http://example.com/nonexistent.jpg")
        .to_return(status: 404)

      stub_request(:get, "http://example.com/img1.jpg")
        .to_return(status: 200, body: "IMAGE_CONTENT_1")
    end

    it 'logs an error and continues with other URLs' do
      expect(logger).to receive(:error).with("Failed to download http://example.com/nonexistent.jpg: 404 ")

      batch_downloader = BatchDownloader.new(sample_file_path, test_images_folder, concurrency, logger)
      batch_downloader.download

      downloaded_files = Dir[File.join(test_images_folder, '*')]
      expect(downloaded_files.count).to eq(1)

      downloaded_files.each do |file|
        content = File.read(file)
        expect(["IMAGE_CONTENT_1"]).to include(content)
      end
    end

    context 'when multiple image URLs have the same image name' do
      before do
        File.write(sample_file_path, "http://example.com/img.jpg\nhttp://anotherexample.com/img.jpg")

        stub_request(:get, "http://example.com/img.jpg")
          .to_return(status: 200, body: "IMAGE_CONTENT_1")

        stub_request(:get, "http://anotherexample.com/img.jpg")
          .to_return(status: 200, body: "IMAGE_CONTENT_2")
      end

      it 'downloads images and ensures filenames are unique' do
        batch_downloader = BatchDownloader.new(sample_file_path, test_images_folder, concurrency, logger)
        batch_downloader.download

        downloaded_files = Dir[File.join(test_images_folder, '*')]
        expect(downloaded_files.count).to eq(2)

        downloaded_file_names = downloaded_files.map { |path| File.basename(path) }

        # Ensure that the filenames are unique
        expect(downloaded_file_names.uniq.count).to eq(downloaded_file_names.count)

        downloaded_files.each do |file|
          content = File.read(file)
          expect(["IMAGE_CONTENT_1", "IMAGE_CONTENT_2"]).to include(content)
        end
      end
    end

  end

end
