# Dog-CLI

CLI to fetch random dog images and list available dog breeds using the [Dog CEO API](https://dog.ceo/dog-api/).

## Prerequisites

- Ruby >= 3.0.0
- Bundler

## Installation

```bash
bundle install
```

## Usage Examples

### Fetch random dog images

```bash
dog random
```

This command outputs the URL of a random dog image fetched from the Dog CEO API.

`random` is the default command, so running `dog` with no arguments is equivalent to `dog random`.

### Fetch multiple random dog images

```bash
dog random --count 3
```

This command outputs three random dog image URLs, one per line.

### Fetch random images for a specific breed

```bash
dog random --breed hound-afghan
dog random --breed hound-afghan --count 2
```

The `--breed` (or `-b`) option filters results to a specific breed. Sub-breeds use a dash separator (e.g. `hound-afghan`).

### Output as JSON

```bash
dog random --format json
dog random --count 3 --format json
dog breeds --format json
```

The `--format` (or `-f`) option accepts `plain` (default, one result per line) or `json`.

### List available dog breeds

```bash
dog breeds
```

This command outputs the list of all available dog breeds, one per line.

```bash
dog list
```

The `list` command is an alias for `breeds`.

## Commands

| Command  | Description                                          |
|----------|------------------------------------------------------|
| `random` | Fetches random dog images (default command)          |
| `breeds` | Lists all available dog breeds                       |
| `list`   | Lists all available dog breeds (alias for `breeds`)  |

## Options

| Option            | Alias | Applies to     | Description                                            |
|-------------------|-------|----------------|--------------------------------------------------------|
| `--breed=BREED`   | `-b`  | `random`       | Fetch images for a specific breed (e.g. `hound-afghan`)|
| `--count=N`       | `-n`  | `random`       | Number of images to fetch (default: 1)                 |
| `--format=FORMAT` | `-f`  | `random`, `breeds`, `list` | Output format: `plain` or `json` (default: `plain`) |

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