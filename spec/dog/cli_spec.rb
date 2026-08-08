# frozen_string_literal: true

require "tmpdir"

RSpec.describe Dog::CLI do
  let(:client) { instance_double(Dog::Client) }
  let(:downloader) { instance_double(Dog::Downloader) }
  let(:cli) { described_class.new([], client: client, downloader: downloader) }
  let(:image_url) { "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg" }

  def set_options(cli, **overrides)
    defaults = { breed: nil, count: 1, format: "plain", download: false, output: nil }
    cli.options = defaults.merge(overrides)
  end

  before do
    set_options(cli)
  end

  describe "#random" do
    context "when the client returns a single random image URL" do
      before do
        allow(client).to receive(:random_image).with(count: 1, breed: nil).and_return(image_url)
      end

      it "outputs the random dog image URL" do
        expect { cli.random }.to output("#{image_url}\n").to_stdout
      end
    end

    context "when the client returns multiple random image URLs" do
      let(:image_urls) do
        [
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1004.jpg"
        ]
      end

      before do
        set_options(cli, count: 2)
        allow(client).to receive(:random_image).with(count: 2, breed: nil).and_return(image_urls)
      end

      it "outputs each random dog image URL on its own line" do
        expect { cli.random }.to output("#{image_urls.join("\n")}\n").to_stdout
      end
    end

    context "when fetching images for a specific breed" do
      before do
        set_options(cli, breed: "hound-afghan")
        allow(client).to receive(:random_image).with(count: 1, breed: "hound-afghan").and_return(image_url)
      end

      it "outputs the random dog image URL for the breed" do
        expect { cli.random }.to output("#{image_url}\n").to_stdout
      end
    end

    context "when the format is json" do
      before do
        set_options(cli, format: "json")
        allow(client).to receive(:random_image).with(count: 1, breed: nil).and_return(image_url)
      end

      it "outputs the images as JSON" do
        expect { cli.random }.to output("#{JSON.generate([image_url])}\n").to_stdout
      end
    end

    context "when downloading images" do
      let(:saved_path) { File.join(Dir.tmpdir, "n02088094_1003.jpg") }

      before do
        set_options(cli, download: true)
        allow(client).to receive(:random_image).with(count: 1, breed: nil).and_return(image_url)
        allow(downloader).to receive(:download).with(image_url).and_return(saved_path)
      end

      it "downloads the image and outputs feedback to stderr" do
        expect { cli.random }.to output(
          "Downloading #{image_url}...\nSaved to #{saved_path}\nDownloaded 1 image(s) successfully.\n"
        ).to_stderr
      end

      it "does not output the image URL to stdout" do
        expect { cli.random }.to_not output(/#{image_url}/).to_stdout
      end
    end

    context "when downloading multiple images" do
      let(:image_urls) do
        [
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1004.jpg"
        ]
      end
      let(:saved_paths) do
        [
          File.join(Dir.tmpdir, "n02088094_1003.jpg"),
          File.join(Dir.tmpdir, "n02088094_1004.jpg")
        ]
      end

      before do
        set_options(cli, count: 2, download: true)
        allow(client).to receive(:random_image).with(count: 2, breed: nil).and_return(image_urls)
        allow(downloader).to receive(:download).with(image_urls[0]).and_return(saved_paths[0])
        allow(downloader).to receive(:download).with(image_urls[1]).and_return(saved_paths[1])
      end

      it "downloads each image and outputs feedback to stderr" do
        expect { cli.random }.to output(
          "Downloading #{image_urls[0]}...\nSaved to #{saved_paths[0]}\n" \
          "Downloading #{image_urls[1]}...\nSaved to #{saved_paths[1]}\n" \
          "Downloaded 2 image(s) successfully.\n"
        ).to_stderr
      end
    end

    context "when downloading with a custom output directory" do
      let(:custom_dir) { Dir.mktmpdir }
      let(:custom_downloader) { instance_double(Dog::Downloader) }
      let(:saved_path) { File.join(custom_dir, "n02088094_1003.jpg") }

      before do
        set_options(cli, download: true, output: custom_dir)
        allow(client).to receive(:random_image).with(count: 1, breed: nil).and_return(image_url)
        allow(Dog::Downloader).to receive(:new).with(custom_dir).and_return(custom_downloader)
        allow(custom_downloader).to receive(:download).with(image_url).and_return(saved_path)
      end

      it "uses a downloader with the custom output directory" do
        expect { cli.random }.to output(
          "Downloading #{image_url}...\nSaved to #{saved_path}\nDownloaded 1 image(s) successfully.\n"
        ).to_stderr
      end
    end

    context "when the download fails" do
      before do
        set_options(cli, download: true)
        allow(client).to receive(:random_image).with(count: 1, breed: nil).and_return(image_url)
        allow(downloader).to receive(:download).with(image_url).and_raise(
          Dog::Errors::DownloadError, "Failed to download #{image_url}: HTTP 404"
        )
        allow(cli).to receive(:exit)
      end

      it "outputs an error message to stderr" do
        expect { cli.random }.to output(
          "Downloading #{image_url}...\nError: Failed to download #{image_url}: HTTP 404\n"
        ).to_stderr
      end

      it "exits with status 1" do
        cli.random
        expect(cli).to have_received(:exit).with(1)
      end
    end

    context "when the count is invalid" do
      before do
        set_options(cli, count: 0)
        allow(client).to receive(:random_image)
        allow(cli).to receive(:exit)
      end

      it "outputs an error message to stderr" do
        expect { cli.random }.to output("Error: --count must be a positive integer\n").to_stderr
      end

      it "exits with status 1" do
        cli.random
        expect(cli).to have_received(:exit).with(1)
      end
    end

    context "when the client raises an APIError" do
      before do
        allow(client).to receive(:random_image).and_raise(
          Dog::Errors::APIError, "Dog CEO API error: Internal Server Error"
        )
        allow(cli).to receive(:exit)
      end

      it "outputs an error message to stderr" do
        expect { cli.random }.to output("Error: Dog CEO API error: Internal Server Error\n").to_stderr
      end

      it "exits with status 1" do
        cli.random
        expect(cli).to have_received(:exit).with(1)
      end
    end

    context "when the client raises an APIError for a breed request" do
      before do
        set_options(cli, breed: "unknown-breed")
        allow(client).to receive(:random_image).and_raise(
          Dog::Errors::APIError, "Dog CEO API error: Breed not found"
        )
        allow(cli).to receive(:exit)
      end

      it "outputs an error message and a tip to stderr" do
        expect { cli.random }.to output(
          "Error: Dog CEO API error: Breed not found\nTip: Use `dog breeds` to see available breeds.\n"
        ).to_stderr
      end

      it "exits with status 1" do
        cli.random
        expect(cli).to have_received(:exit).with(1)
      end
    end

    context "when the client raises an InvalidResponseError" do
      before do
        allow(client).to receive(:random_image).and_raise(
          Dog::Errors::InvalidResponseError, "Unexpected response from Dog CEO API"
        )
        allow(cli).to receive(:exit)
      end

      it "outputs an error message to stderr" do
        expect { cli.random }.to output("Error: Unexpected response from Dog CEO API\n").to_stderr
      end

      it "exits with status 1" do
        cli.random
        expect(cli).to have_received(:exit).with(1)
      end
    end
  end

  describe "#breeds" do
    let(:breeds) { %w[affenpinscher hound retriever] }

    context "when the client returns the list of breeds" do
      before do
        allow(client).to receive(:breeds).and_return(breeds)
      end

      it "outputs each breed on its own line" do
        expect { cli.breeds }.to output("#{breeds.join("\n")}\n").to_stdout
      end
    end

    context "when the format is json" do
      before do
        set_options(cli, format: "json")
        allow(client).to receive(:breeds).and_return(breeds)
      end

      it "outputs the breeds as JSON" do
        expect { cli.breeds }.to output("#{JSON.generate(breeds)}\n").to_stdout
      end
    end

    context "when the client raises an APIError" do
      before do
        allow(client).to receive(:breeds).and_raise(
          Dog::Errors::APIError, "Dog CEO API error: Internal Server Error"
        )
        allow(cli).to receive(:exit)
      end

      it "outputs an error message to stderr" do
        expect { cli.breeds }.to output("Error: Dog CEO API error: Internal Server Error\n").to_stderr
      end

      it "exits with status 1" do
        cli.breeds
        expect(cli).to have_received(:exit).with(1)
      end
    end
  end

  describe "#list" do
    let(:breeds) { %w[affenpinscher hound retriever] }

    before do
      allow(client).to receive(:breeds).and_return(breeds)
    end

    it "outputs each breed on its own line" do
      expect { cli.list }.to output("#{breeds.join("\n")}\n").to_stdout
    end
  end
end