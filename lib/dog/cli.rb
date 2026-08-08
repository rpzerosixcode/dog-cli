# frozen_string_literal: true

require "thor"
require "json"

module Dog
  # Dog command line interface.
  class CLI < Thor
    default_command :random

    # Initializes the CLI with a client.
    #
    # @param client [Client] the HTTP client used to fetch dog images
    # @param downloader [Downloader] the downloader used to save images locally
    def initialize(*args, client: Client.new, downloader: Downloader.new)
      super(*args)
      @client = client
      @downloader = downloader
    end

    # Ensures Thor exits with a non-zero status code on errors.
    def self.exit_on_failure?
      true
    end

    desc "random", "Fetches random dog images"
    long_desc <<~LONGDESC
      Fetches random dog images from the Dog CEO API.

      Examples:

        $ dog random                          # Fetch one random image
        $ dog random --count 3                # Fetch three random images
        $ dog random --breed hound-afghan     # Fetch a random hound-afghan image
        $ dog random --breed hound --count 2  # Fetch two random hound images
        $ dog random --format json            # Output as JSON
        $ dog random --download               # Save image to ~/dog_images/
        $ dog random --download --output ./pics  # Save to custom directory
        $ dog random --count 3 --download     # Save multiple images locally
    LONGDESC
    method_option :breed, type: :string, aliases: "-b",
                          desc: "Fetch images for a specific breed (e.g. hound-afghan)"
    method_option :count, type: :numeric, aliases: "-n", default: 1,
                          desc: "Number of images to fetch (default: 1)"
    method_option :format, type: :string, aliases: "-f", default: "plain",
                           enum: %w[plain json],
                           desc: "Output format: plain or json (default: plain)"
    method_option :download, type: :boolean, aliases: "-d",
                             desc: "Save images to the local output directory"
    method_option :output, type: :string, aliases: "-o",
                           desc: "Directory to save images to (default: ~/dog_images)"
    def random
      count = validate_count!(options[:count])
      images = fetch_images(count)
      options[:download] ? download_images(images) : output_images(images)
    rescue Errors::APIError => e
      warn "Error: #{e.message}"
      warn "Tip: Use `dog breeds` to see available breeds." if options[:breed]
      exit 1
    rescue Errors::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    desc "breeds", "Lists all available dog breeds"
    long_desc <<~LONGDESC
      Lists all dog breeds available in the Dog CEO API.

      Examples:

        $ dog breeds                # List all breeds
        $ dog breeds --format json  # List breeds as JSON
    LONGDESC
    method_option :format, type: :string, aliases: "-f", default: "plain",
                           enum: %w[plain json],
                           desc: "Output format: plain or json (default: plain)"
    def breeds
      output_breeds(client.breeds)
    rescue Errors::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    desc "list", "Lists all available dog breeds (alias for breeds)"
    method_option :format, type: :string, aliases: "-f", default: "plain",
                           enum: %w[plain json],
                           desc: "Output format: plain or json (default: plain)"
    def list
      breeds
    end

    private

    attr_reader :client, :downloader

    def fetch_images(count)
      images = client.random_image(count: count, breed: options[:breed])
      images.is_a?(Array) ? images : [images]
    end

    def download_images(images)
      downloader = build_downloader
      images.each do |url|
        feedback "Downloading #{url}..."
        path = downloader.download(url)
        feedback "Saved to #{path}"
      end
      feedback "Downloaded #{images.size} image(s) successfully."
    end

    def build_downloader
      return downloader unless options[:output]

      Downloader.new(options[:output])
    end

    def feedback(message)
      warn message
    end

    def validate_count!(count)
      count = count.to_i
      return count if count.positive?

      warn "Error: --count must be a positive integer"
      exit 1
    end

    def output_images(images)
      case options[:format]
      when "json"
        puts JSON.generate(images)
      else
        puts images
      end
    end

    def output_breeds(breeds)
      case options[:format]
      when "json"
        puts JSON.generate(breeds)
      else
        puts breeds
      end
    end
  end
end
