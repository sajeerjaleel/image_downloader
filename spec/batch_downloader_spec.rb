require_relative '../lib/downloader/batch_downloader'

RSpec.describe BatchDownloader do
  let(:file_path) { "spec/fixtures/urls.txt" }
  let(:images_folder) { "spec/fixtures/images" }
  let(:concurrency) { 5 }
  let(:logger) { instance_double("Logger", error: nil, info: nil) }
  let(:url_reader) { instance_double("URLReader") }
  let(:image_downloader) { instance_double("ImageDownloader", download: nil) }

  before do
    FileUtils.mkdir_p(images_folder)
    allow(URLReader).to receive(:new).and_return(url_reader)
    allow(ImageDownloader).to receive(:new).and_return(image_downloader)
  end

  after do
    FileUtils.rm_rf(images_folder)
  end

  describe '#download' do
    context 'with valid setup' do
      it 'processes URLs and downloads images' do
        urls = ["http://example.com/img1.jpg", "http://example.com/img2.jpg"]
        allow(url_reader).to receive(:each_valid_url) { |&block| urls.each(&block) }

        expect(image_downloader).to receive(:download).twice

        downloader = BatchDownloader.new(file_path, images_folder, concurrency, logger)
        downloader.download

        expect(logger).to have_received(:info).with("Download complete!")
      end
    end

    context 'when an error occurs during image download' do
      it 'logs the error and continues processing' do
        urls = ["http://example.com/img1.jpg", "http://example.com/img2.jpg"]
        allow(url_reader).to receive(:each_valid_url) { |&block| urls.each(&block) }

        allow(image_downloader).to receive(:download).and_raise("Image download error")

        downloader = BatchDownloader.new(file_path, images_folder, concurrency, logger)
        expect { downloader.download }.not_to raise_error

        expect(logger).to have_received(:error).at_least(:once)
        expect(logger).to have_received(:info).with("Download complete!")
      end
    end

    context 'when an error occurs during URL processing' do
      it 'logs the error and completes with a failure message' do
        allow(url_reader).to receive(:each_valid_url).and_raise("URL processing error")

        downloader = BatchDownloader.new(file_path, images_folder, concurrency, logger)
        expect { downloader.download }.not_to raise_error

        expect(logger).to have_received(:error).with("An unexpected error occurred: URL processing error")
      end
    end

  end
end
