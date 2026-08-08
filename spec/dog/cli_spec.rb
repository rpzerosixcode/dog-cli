# frozen_string_literal: true

RSpec.describe Dog::CLI do
  let(:client) { instance_double(Dog::Client) }
  let(:cli) { described_class.new([], client: client) }
  let(:image_url) { "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg" }

  def set_options(cli, **overrides)
    defaults = { breed: nil, count: 1, format: "plain" }
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