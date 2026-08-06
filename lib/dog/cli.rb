# frozen_string_literal: true

require "thor"

module Dog
  # Dog command line interface.
  class CLI < Thor
    # Initializes the CLI with a client.
    #
    # @param client [Client] the HTTP client used to fetch dog images
    def initialize(*args, client: Client.new)
      super(*args)
      @client = client
    end

    desc "random", "Fetches a random dog image"
    def random
      puts client.random_image
    rescue Errors::Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    private

    attr_reader :client
  end
end