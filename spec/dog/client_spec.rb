# frozen_string_literal: true

RSpec.describe Dog::Client do
  let(:base_url) { "https://dog.ceo/api" }
  let(:client) { described_class.new(base_url) }
  let(:image_url) { "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg" }

  describe "#random_image" do
    context "when fetching a single random image" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 200, body: { status: "success", message: image_url }.to_json)
      end

      it "returns the random dog image URL" do
        expect(client.random_image).to eq(image_url)
      end
    end

    context "when fetching multiple random images" do
      let(:image_urls) do
        [
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1004.jpg"
        ]
      end

      before do
        stub_request(:get, "#{base_url}/breeds/image/random/2")
          .to_return(status: 200, body: { status: "success", message: image_urls }.to_json)
      end

      it "returns an array of random dog image URLs" do
        expect(client.random_image(count: 2)).to eq(image_urls)
      end
    end

    context "when fetching a random image for a specific breed" do
      before do
        stub_request(:get, "#{base_url}/breed/hound/afghan/images/random")
          .to_return(status: 200, body: { status: "success", message: image_url }.to_json)
      end

      it "returns the random dog image URL for the breed" do
        expect(client.random_image(breed: "hound-afghan")).to eq(image_url)
      end
    end

    context "when fetching multiple random images for a specific breed" do
      let(:image_urls) do
        [
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
          "https://images.dog.ceo/breeds/hound-afghan/n02088094_1004.jpg"
        ]
      end

      before do
        stub_request(:get, "#{base_url}/breed/hound/afghan/images/random/2")
          .to_return(status: 200, body: { status: "success", message: image_urls }.to_json)
      end

      it "returns an array of random dog image URLs for the breed" do
        expect(client.random_image(count: 2, breed: "hound-afghan")).to eq(image_urls)
      end
    end

    context "when the breed contains a sub-breed separator" do
      before do
        stub_request(:get, "#{base_url}/breed/hound/afghan/images/random")
          .to_return(status: 200, body: { status: "success", message: image_url }.to_json)
      end

      it "converts the dash to a slash in the API path" do
        expect(client.random_image(breed: "hound-afghan")).to eq(image_url)
      end
    end

    context "when the API returns an HTTP error response" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 500, body: { status: "error", message: "Internal Server Error" }.to_json)
      end

      it "raises an APIError with the API error message" do
        expect { client.random_image }.to raise_error(
          Dog::Errors::APIError,
          "Dog CEO API error: Internal Server Error"
        )
      end
    end

    context "when the API returns a non-success status in the payload" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 200, body: { status: "error", message: "No route found" }.to_json)
      end

      it "raises an InvalidResponseError" do
        expect { client.random_image }.to raise_error(
          Dog::Errors::InvalidResponseError,
          "Unexpected response from Dog CEO API"
        )
      end
    end

    context "when the API returns a message that is not a String or Array" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 200, body: { status: "success", message: { "foo" => "bar" } }.to_json)
      end

      it "raises an InvalidResponseError" do
        expect { client.random_image }.to raise_error(
          Dog::Errors::InvalidResponseError,
          "Unexpected response from Dog CEO API"
        )
      end
    end

    context "when the API returns an invalid JSON response" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 200, body: "not valid json")
      end

      it "raises an InvalidResponseError" do
        expect { client.random_image }.to raise_error(
          Dog::Errors::InvalidResponseError,
          "Invalid JSON response from Dog CEO API"
        )
      end
    end

    context "when the API returns an empty body" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 200, body: "")
      end

      it "raises an InvalidResponseError" do
        expect { client.random_image }.to raise_error(
          Dog::Errors::InvalidResponseError,
          "Invalid JSON response from Dog CEO API"
        )
      end
    end
  end

  describe "#breeds" do
    context "when the API returns a successful response" do
      let(:breeds_hash) do
        {
          "affenpinscher" => [],
          "hound" => %w[afghan basset blood english ibizan plott walker],
          "retriever" => %w[chesapeake curly flat-coated golden]
        }
      end

      before do
        stub_request(:get, "#{base_url}/breeds/list/all")
          .to_return(status: 200, body: { status: "success", message: breeds_hash }.to_json)
      end

      it "returns the sorted list of available breeds" do
        expect(client.breeds).to eq(%w[affenpinscher hound retriever])
      end
    end

    context "when the API returns an HTTP error response" do
      before do
        stub_request(:get, "#{base_url}/breeds/list/all")
          .to_return(status: 500, body: { status: "error", message: "Internal Server Error" }.to_json)
      end

      it "raises an APIError with the API error message" do
        expect { client.breeds }.to raise_error(
          Dog::Errors::APIError,
          "Dog CEO API error: Internal Server Error"
        )
      end
    end

    context "when the API returns a message that is not a Hash" do
      before do
        stub_request(:get, "#{base_url}/breeds/list/all")
          .to_return(status: 200, body: { status: "success", message: "not-a-hash" }.to_json)
      end

      it "raises an InvalidResponseError" do
        expect { client.breeds }.to raise_error(
          Dog::Errors::InvalidResponseError,
          "Unexpected response from Dog CEO API"
        )
      end
    end

    context "when the API returns an invalid JSON response" do
      before do
        stub_request(:get, "#{base_url}/breeds/list/all")
          .to_return(status: 200, body: "not valid json")
      end

      it "raises an InvalidResponseError" do
        expect { client.breeds }.to raise_error(
          Dog::Errors::InvalidResponseError,
          "Invalid JSON response from Dog CEO API"
        )
      end
    end
  end
end