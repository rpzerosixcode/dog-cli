# Dog-CLI

CLI to fetch random dog images using the [Dog CEO API](https://dog.ceo/dog-api/).

## Prerequisites

- Ruby >= 3.0.0
- Bundler

## Installation

```bash
bundle install
```

## Usage Examples

Fetch a random dog image:

```bash
dog random
```

This command outputs the URL of a random dog image fetched from the Dog CEO API.

## Project Structure

```
dog-cli/
├── .rspec                     # RSpec configuration
├── .rubocop.yml               # RuboCop configuration
├── .gitignore                 # Files ignored by Git
├── Gemfile                    # Gem dependencies
├── LICENSE                    # MIT license of the project
├── Rakefile                   # Automation tasks (spec, rubocop)
├── README.md                  # Project documentation
├── dog-cli.gemspec            # Gem specification
├── docs/
│   └── ROADMAP.md             # Project roadmap
├── exe/
│   └── dog                    # CLI executable
├── lib/
│   ├── dog.rb                 # Library entry point
│   └── dog/
│       ├── cli.rb             # Command line interface (Thor)
│       ├── client.rb          # HTTP client (Net::HTTP) for the Dog CEO API
│       ├── errors.rb          # Custom errors
│       └── version.rb         # Gem version
└── spec/
    └── spec_helper.rb         # Test configuration
    └── dog/
        └── cli_spec.rb        # CLI tests
        └── client_spec.rb     # Client tests
```

## Documentation

- [Roadmap](docs/ROADMAP.md) — planning of future versions

## Contribution

To be defined in the future.

## License

This project is licensed under the [MIT License](LICENSE).

Copyright (c) 2026 Ruan Pablo Dos Santos Gonçalves.