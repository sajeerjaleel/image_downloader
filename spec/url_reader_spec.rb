require_relative '../lib/downloader/url_reader'

describe URLReader do
  let(:logger) { instance_double("Logger", warn: nil, error: nil) }
  let(:file_path) { 'test_file.txt' }

  before do
    allow(File).to receive(:exist?).and_return(true)
  end

  describe '#initialize' do
    it 'raises an error if the file does not exist' do
      allow(File).to receive(:exist?).and_return(false)
      expect { URLReader.new(file_path) }.to raise_error(Errno::ENOENT)
    end
  end

  describe '#each_valid_url' do
    let(:valid_url) { "http://example.com/image.jpg" }
    let(:invalid_url) { "http://example.com/not_image.txt" }

    before do
      allow(File).to receive(:foreach).and_yield("#{valid_url} #{invalid_url}")
    end

    it 'yields only valid image URLs' do
      reader = URLReader.new(file_path, logger)
      expect { |b| reader.each_valid_url(&b) }.to yield_with_args(valid_url)
    end

    it 'logs a warning for invalid URLs' do
      expect(logger).to receive(:warn).with("Invalid image URL: #{invalid_url}")
      reader = URLReader.new(file_path, logger)
      reader.each_valid_url {}
    end

    context 'when an unexpected error occurs' do
      before do
        allow(File).to receive(:foreach).and_raise(StandardError.new("Unexpected error!"))
      end

      it 'logs an error message' do
        expect(logger).to receive(:error).with("An unexpected error occurred while reading file: #{file_path}. Error: Unexpected error!")
        reader = URLReader.new(file_path, logger)
        reader.each_valid_url {}
      end
    end
  end

  describe '#valid_image_url?' do
    # Since the method is private, we'll be testing it through #each_valid_url
    let(:jpg_url) { "http://example.com/image.jpg" }
    let(:txt_url) { "http://example.com/file.txt" }

    it 'validates jpg image URLs' do
      allow(File).to receive(:foreach).and_yield(jpg_url)
      reader = URLReader.new(file_path, logger)
      expect { |b| reader.each_valid_url(&b) }.to yield_with_args(jpg_url)
    end

    it 'does not yield non-image URLs' do
      allow(File).to receive(:foreach).and_yield(txt_url)
      reader = URLReader.new(file_path, logger)
      expect { |b| reader.each_valid_url(&b) }.not_to yield_control
    end
  end
end
