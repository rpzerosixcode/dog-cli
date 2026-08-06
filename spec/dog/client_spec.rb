# frozen_string_literal: true

RSpec.describe Dog::Client do
  describe "#random_image" do
    let(:base_url) { "https://dog.ceo/api" }
    let(:client) { described_class.new(base_url) }
    let(:image_url) { "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg" }

    context "when the API returns a successful response" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 200, body: { status: "success", message: image_url }.to_json)
      end

      it "returns the random dog image URL" do
        expect(client.random_image).to eq(image_url)
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

    context "when the API returns a message that is not a String" do
      before do
        stub_request(:get, "#{base_url}/breeds/image/random")
          .to_return(status: 200, body: { status: "success", message: [image_url] }.to_json)
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
end