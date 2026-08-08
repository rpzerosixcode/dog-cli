# frozen_string_literal: true

require "net/http"
require "uri"
require "fileutils"

module Dog
  # Downloads dog images from URLs to a local directory.
  class Downloader
    DEFAULT_OUTPUT_DIR = File.expand_path("~/dog_images")

    # Initializes a new downloader.
    #
    # @param output_dir [String] the directory to save images to
    def initialize(output_dir = DEFAULT_OUTPUT_DIR)
      @output_dir = output_dir
    end

    # Downloads an image from the given URL and saves it to the output directory.
    #
    # @param url [String] the URL of the image to download
    # @return [String] the path to the saved image
    # @raise [Errors::DownloadError] if the download fails
    def download(url)
      FileUtils.mkdir_p(@output_dir)

      filename = build_filename(url)
      path = File.join(@output_dir, filename)

      uri = URI(url)
      response = Net::HTTP.get_response(uri)

      unless response.is_a?(Net::HTTPSuccess)
        raise Errors::DownloadError, "Failed to download #{url}: HTTP #{response.code}"
      end

      File.binwrite(path, response.body)
      path
    end

    private

    def build_filename(url)
      # Extract filename from URL, or use a hash-based name
      basename = File.basename(URI.parse(url).path)
      basename = "dog_#{Time.now.to_i}.jpg" if basename.nil? || basename.empty?
      basename
    end
  end
end
