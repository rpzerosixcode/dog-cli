# frozen_string_literal: true

RSpec.describe Dog::Downloader do
  let(:output_dir) { Dir.mktmpdir }
  let(:downloader) { described_class.new(output_dir) }
  let(:image_url) { "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg" }

  after do
    FileUtils.rm_rf(output_dir)
  end

  describe "#download" do
    context "when the download succeeds" do
      before do
        stub_request(:get, image_url)
          .to_return(status: 200, body: "fake-image-bytes")
      end

      it "saves the image to the output directory" do
        path = downloader.download(image_url)
        expect(File.exist?(path)).to be(true)
        expect(File.read(path)).to eq("fake-image-bytes")
      end

      it "returns the path of the saved image" do
        path = downloader.download(image_url)
        expect(path).to eq(File.join(output_dir, "n02088094_1003.jpg"))
      end

      it "creates the output directory if it does not exist" do
        FileUtils.rm_rf(output_dir)
        downloader.download(image_url)
        expect(Dir.exist?(output_dir)).to be(true)
      end
    end

    context "when the download fails" do
      before do
        stub_request(:get, image_url)
          .to_return(status: 404, body: "Not Found")
      end

      it "raises a DownloadError" do
        expect { downloader.download(image_url) }.to raise_error(
          Dog::Errors::DownloadError,
          "Failed to download #{image_url}: HTTP 404"
        )
      end
    end
  end
end