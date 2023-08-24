require_relative '../lib/downloader/image_downloader'

describe ImageDownloader do
  let(:url) { "http://example.com/test_image.jpg" }
  let(:images_folder) { "/tmp/images" }
  let(:logger) { instance_double("Logger", info: nil, error: nil) }

  subject { ImageDownloader.new(url, images_folder, logger) }

  describe '#download' do
    let(:file_name) { "test_image.jpg" }
    let(:destination_path) { File.join(images_folder, file_name) }
    before do
      allow(URI).to receive(:open).with(url).and_yield(StringIO.new("mock image data"))
      allow(File).to receive(:open).and_call_original
    end

    context 'when the image is downloaded without errors' do

      before do
        FileUtils.mkdir_p("some_folder")
      end

      after do
        FileUtils.rm_rf("some_folder")
      end

      it 'downloads an image' do
        expect(URI).to receive(:open).with(url).and_yield(StringIO.new("mock image data"))
        subject.download
      end

      it 'downloads the image from a valid URL' do
        expect(File).to receive(:open).with(destination_path, 'wb')
        subject.download
      end

      it 'downloads an image and logs a success message' do
        downloader = ImageDownloader.new(url, "some_folder", logger)

        expect(URI).to receive(:open).with(url).and_yield(StringIO.new("mock image data"))
        expect(logger).to receive(:info).with("Downloaded #{file_name}")

        downloader.download
      end

    end

    context 'when there is an HTTP error' do
      before do
        allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new('Error message', nil))
      end

      it 'logs an error message' do
        expect(logger).to receive(:error).with("Failed to download #{url}: Error message")
        subject.download
      end
    end

    context 'when there is a file access error' do
      before do
        allow(File).to receive(:open).and_raise(Errno::EACCES.new())
      end

      it 'logs an error message' do
        expect { subject.download }.to raise_error(Errno::EACCES)
        expect(logger).to have_received(:error).with("Permission denied while writing to #{images_folder}: Permission denied")
      end
    end

    context 'when there is an unexpected error' do
      before do
        allow(URI).to receive(:open).and_raise(StandardError.new("Unexpected error!"))
      end

      it 'logs an error message' do
        expect(logger).to receive(:error).with("An error occurred while downloading #{url}: Unexpected error!")
        subject.download
      end
    end
  end
end
