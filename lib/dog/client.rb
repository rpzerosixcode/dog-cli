# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module Dog
  # HTTP client for the Dog CEO API.
  class Client
    DEFAULT_BASE_URL = "https://dog.ceo/api"

    # Initializes a new client.
    #
    # @param base_url [String] the base URL of the Dog CEO API
    def initialize(base_url = DEFAULT_BASE_URL)
      @base_url = base_url
    end

    # Fetches a random dog image URL from the Dog CEO API.
    #
    # @return [String] the URL of a random dog image
    # @raise [Errors::APIError] if the API returns an error response
    # @raise [Errors::InvalidResponseError] if the API returns an unexpected response
    def random_image
      response = get("/breeds/image/random")
      parse_response(response)
    end

    private

    attr_reader :base_url

    def get(path)
      uri = URI("#{base_url}#{path}")
      Net::HTTP.get_response(uri)
    end

    def parse_response(response)
      body = parse_body(response)
      validate_success!(response, body)
      validate_payload!(body)

      body["message"]
    end

    def parse_body(response)
      JSON.parse(response.body)
    rescue JSON::ParserError
      raise Errors::InvalidResponseError, "Invalid JSON response from Dog CEO API"
    end

    def validate_success!(response, body)
      return if response.is_a?(Net::HTTPSuccess)

      raise Errors::APIError, "Dog CEO API error: #{body['message']}"
    end

    def validate_payload!(body)
      return if body["status"] == "success" && body["message"].is_a?(String)

      raise Errors::InvalidResponseError, "Unexpected response from Dog CEO API"
    end
  end
end