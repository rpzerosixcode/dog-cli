# Architecture

## Overview

Dog-CLI is a command-line tool that fetches random dog images and lists available dog breeds using the [Dog CEO API](https://dog.ceo/dog-api/). It is implemented as a Ruby gem with a Thor-based CLI, a Net::HTTP-based API client, and a file-download utility.

## Module Structure

```
lib/
├── dog.rb              # Library entry point; requires all sub-modules
└── dog/
    ├── cli.rb          # Thor-based command line interface
    ├── client.rb       # HTTP client for the Dog CEO API
    ├── downloader.rb   # Image download utility
    ├── errors.rb       # Custom error classes
    └── version.rb      # Gem version constant
```

## Components

### Dog::CLI

The `Dog::CLI` class extends `Thor` and provides the user-facing commands. It is the entry point invoked by the `exe/dog` executable.

**Commands:**

| Command  | Description                                          |
|----------|------------------------------------------------------|
| `random` | Fetches random dog images (default command)          |
| `breeds` | Lists all available dog breeds                       |
| `list`   | Lists all available dog breeds (alias for `breeds`)  |

**Options:**

| Option            | Alias | Applies to              | Description                                            |
|-------------------|-------|-------------------------|--------------------------------------------------------|
| `--breed=BREED`   | `-b`  | `random`                | Fetch images for a specific breed (e.g. `hound-afghan`)|
| `--count=N`       | `-n`  | `random`                | Number of images to fetch (default: 1)                 |
| `--format=FORMAT` | `-f`  | `random`, `breeds`, `list` | Output format: `plain` or `json` (default: `plain`) |
| `--download`      | `-d`  | `random`                | Save images to the local output directory              |
| `--output=DIR`    | `-o`  | `random` (with `--download`) | Directory to save images to (default: `~/dog_images`) |

**Design decisions:**

- The CLI accepts injectable `client` and `downloader` dependencies via keyword arguments, enabling easy testing with doubles.
- Error handling is centralized in `rescue` blocks within each command method. `APIError` and `InvalidResponseError` are caught in `random`; `Error` (the base class) is caught in `breeds`.
- When a breed-specific request fails with an `APIError`, a tip suggesting `dog breeds` is printed to stderr.
- `exit_on_failure?` is defined to return `true`, ensuring Thor exits with a non-zero status code on errors.

### Dog::Client

The `Dog::Client` class wraps the Dog CEO API using Ruby's standard `Net::HTTP` library. It has no external dependencies beyond the Ruby standard library.

**Public methods:**

- `random_image(count:, breed:)` — Fetches one or more random dog image URLs. Returns a `String` for a single image or an `Array<String>` for multiple images.
- `breeds` — Fetches and returns a sorted `Array<String>` of all available breed names.

**Internal flow:**

1. Build the API path based on the requested parameters (breed, count).
2. Send an HTTP GET request via `Net::HTTP.get_response`.
3. Parse the JSON response body.
4. Validate the HTTP status (raise `APIError` on non-success).
5. Validate the payload structure (raise `InvalidResponseError` on unexpected format).
6. Extract and return the `message` field.

**Breed path handling:**

Sub-breeds are specified with a dash separator (e.g. `hound-afghan`). The client converts the dash to a slash for the API path (e.g. `/breed/hound/afghan/images/random`).

### Dog::Downloader

The `Dog::Downloader` class downloads image files from URLs to a local directory using `Net::HTTP` and `FileUtils`.

**Public methods:**

- `download(url)` — Downloads the image at the given URL and saves it to the output directory. Returns the path to the saved file. Raises `DownloadError` on HTTP failure.

**Design decisions:**

- The output directory is created automatically via `FileUtils.mkdir_p` if it does not exist.
- The filename is extracted from the URL path. If the URL has no filename, a timestamp-based name is generated.
- The default output directory is `~/dog_images`.

### Dog::Errors

A module containing custom error classes that form a hierarchy:

```
Error (StandardError)
├── APIError              # Dog CEO API returned an error response
├── InvalidResponseError  # Dog CEO API returned an unexpected response
└── DownloadError         # Image download failed
```

All custom errors inherit from `Dog::Errors::Error`, which inherits from `StandardError`. This allows the CLI to catch all Dog-specific errors with a single `rescue Errors::Error` clause.

## Data Flow

### Fetching random images

```
exe/dog → Dog::CLI#random → Dog::Client#random_image → Dog CEO API
                                                           ↓
                                                       JSON response
                                                           ↓
                                                       Parse & validate
                                                           ↓
                                                       Return URL(s)
                                                           ↓
                                                       Output or download
```

### Listing breeds

```
exe/dog → Dog::CLI#breeds → Dog::Client#breeds → Dog CEO API
                                                       ↓
                                                   JSON response
                                                       ↓
                                                   Parse & validate
                                                       ↓
                                                   Return sorted breed list
                                                       ↓
                                                   Output (plain or JSON)
```

### Downloading images

```
exe/dog → Dog::CLI#random (with --download) → Dog::Downloader#download → Image URL
                                                                                 ↓
                                                                           HTTP GET
                                                                                 ↓
                                                                           Save to file
                                                                                 ↓
                                                                           Return path
```

## Testing Strategy

The project uses RSpec with WebMock for HTTP request stubbing. Tests are organized by component:

- `spec/dog/client_spec.rb` — Tests the API client with stubbed HTTP responses, covering success cases, HTTP errors, invalid JSON, and unexpected payload structures.
- `spec/dog/cli_spec.rb` — Tests the CLI using instance doubles for `Client` and `Downloader`, covering all commands, options, output formats, and error scenarios.
- `spec/dog/downloader_spec.rb` — Tests the downloader with stubbed HTTP responses, covering successful downloads, directory creation, and download failures.

The default Rake task runs both RuboCop (style enforcement) and RSpec (tests), ensuring code quality and correctness are validated together.
