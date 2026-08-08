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

    # Fetches random dog image URLs from the Dog CEO API.
    #
    # @param count [Integer] the number of images to fetch (default: 1)
    # @param breed [String, nil] the breed to fetch images for (default: any breed)
    # @return [String, Array<String>] a single image URL or an array of image URLs
    # @raise [Errors::APIError] if the API returns an error response
    # @raise [Errors::InvalidResponseError] if the API returns an unexpected response
    def random_image(count: 1, breed: nil)
      response = get(random_image_path(count: count, breed: breed))
      parse_response(response)
    end

    # Fetches the list of available breeds from the Dog CEO API.
    #
    # @return [Array<String>] the list of available breeds
    # @raise [Errors::APIError] if the API returns an error response
    # @raise [Errors::InvalidResponseError] if the API returns an unexpected response
    def breeds
      response = get("/breeds/list/all")
      parse_breeds_response(response)
    end

    private

    attr_reader :base_url

    def random_image_path(count: 1, breed: nil)
      if breed
        "/breed/#{breed_path(breed)}/images/random#{count_suffix(count)}"
      else
        "/breeds/image/random#{count_suffix(count)}"
      end
    end

    def breed_path(breed)
      breed.tr("-", "/")
    end

    def count_suffix(count)
      count > 1 ? "/#{count}" : ""
    end

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

    def parse_breeds_response(response)
      body = parse_body(response)
      validate_success!(response, body)
      validate_breeds_payload!(body)

      body["message"].keys.sort
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
      message = body["message"]
      valid = body["status"] == "success" && (message.is_a?(String) || message.is_a?(Array))
      return if valid

      raise Errors::InvalidResponseError, "Unexpected response from Dog CEO API"
    end

    def validate_breeds_payload!(body)
      return if body["status"] == "success" && body["message"].is_a?(Hash)

      raise Errors::InvalidResponseError, "Unexpected response from Dog CEO API"
    end
  end
end
