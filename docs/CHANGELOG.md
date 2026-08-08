# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-08

### Summary

Stable release of the Dog CLI tool. The project is now feature-complete and ready for general use.

### Added

- **Image download support** (`v0.3.0`): The `random` command now accepts a `--download` (`-d`) flag to save fetched images locally. Images are saved to `~/dog_images/` by default, or to a custom directory via `--output` (`-o`).
- **Custom output directory** (`v0.3.0`): The `--output` (`-o`) option allows specifying a custom directory for downloaded images.
- **Download feedback** (`v0.3.0`): Progress messages are printed to stderr during download operations, including the source URL, saved path, and a summary count.
- **Breed-specific image fetching** (`v0.2.0`): The `--breed` (`-b`) option filters random image results to a specific breed. Sub-breeds use a dash separator (e.g. `hound-afghan`).
- **Multiple image fetching** (`v0.2.0`): The `--count` (`-n`) option fetches multiple random images in a single run.
- **JSON output format** (`v0.2.0`): The `--format` (`-f`) option accepts `plain` (default) or `json` for structured output.
- **Breed listing** (`v0.2.0`): The `breeds` command lists all available dog breeds. The `list` command is provided as an alias.
- **Error handling** (`v0.1.0`): API errors, invalid responses, and download failures are caught and reported with clear error messages. A tip suggesting `dog breeds` is shown when a breed-specific request fails.
- **Invalid count validation** (`v0.1.0`): The `--count` option is validated to ensure it is a positive integer.
- **MFA requirement** (`v1.0.0`): The gemspec now declares `rubygems_mfa_required` metadata for enhanced publishing security.

### Changed

- **Development dependencies** (`v1.0.0`): Development dependencies (`rake`, `rspec`, `rubocop`, `webmock`) have been moved from the gemspec to the `Gemfile` under the `:development` group, following modern Ruby gem best practices.
- **Dependency ordering** (`v1.0.0`): Runtime dependencies in the gemspec are now sorted alphabetically (`net-http` before `thor`).
- **Line ending consistency** (`v1.0.0`): RuboCop `Layout/EndOfLine` is configured to enforce LF line endings for cross-platform compatibility.
- **Thor error handling** (`v1.0.0`): The CLI now defines `exit_on_failure?` to ensure Thor exits with a non-zero status code on errors, silencing the deprecation warning.

### Fixed

- **Extra blank line in executable** (`v1.0.0`): Removed an extra blank line in `exe/dog`.
- **Trailing newlines** (`v1.0.0`): Added missing final newlines to all source and spec files.
- **Gemspec files list** (`v1.0.0`): The `exe/dog` executable and documentation files (`ARCHITECTURE.md`, `CHANGELOG.md`) are now included in the gemspec's `spec.files`, ensuring they are packaged with the gem.

## [0.3.0] - 2026-07-28

### Added

- Image download support via the `--download` (`-d`) flag.
- Custom output directory via the `--output` (`-o`) option.
- Download progress feedback to stderr.

## [0.2.0] - 2026-07-21

### Added

- Breed-specific image fetching via the `--breed` (`-b`) option.
- Multiple image fetching via the `--count` (`-n`) option.
- JSON output format via the `--format` (`-f`) option.
- `breeds` command to list all available dog breeds.
- `list` command as an alias for `breeds`.

## [0.1.0] - 2026-07-14

### Added

- Initial release of the Dog CLI tool.
- `random` command (default) to fetch random dog images from the Dog CEO API.
- HTTP client for the Dog CEO API with error handling.
- Custom error classes: `APIError`, `InvalidResponseError`, `DownloadError`.
- RSpec test suite covering client, CLI, and downloader.
- RuboCop style enforcement.
- Basic project documentation.
