# frozen_string_literal: true

module Dog
  # Custom Dog errors.
  module Errors
    # Base error for the Dog gem.
    class Error < StandardError; end

    # Raised when the Dog CEO API returns an error response.
    class APIError < Error; end

    # Raised when the Dog CEO API returns an unexpected response.
    class InvalidResponseError < Error; end

    # Raised when an image fails to download.
    class DownloadError < Error; end
  end
end
