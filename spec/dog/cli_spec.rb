# frozen_string_literal: true

RSpec.describe Dog::CLI do
  let(:client) { instance_double(Dog::Client) }
  let(:cli) { described_class.new([], client: client) }

  describe "#random" do
    context "when the client returns a random image URL" do
      let(:image_url) { "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg" }

      before do
        allow(client).to receive(:random_image).and_return(image_url)
      end

      it "outputs the random dog image URL" do
        expect { cli.random }.to output("#{image_url}\n").to_stdout
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
end