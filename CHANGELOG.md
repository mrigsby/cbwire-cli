# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-10-24

### Added

- `cbwire dev server stop` to stop any running test-harness servers
- `cbwire dev tests` to run TestBox tests for one or all engines configured for the test-harness server
- Commands now use CommandBox serverService to verify servers are running before running tests or opening webRunner when appropriate

## [1.0.0] - 2025-10-19

### Added

- `boxlang` argument to `cbwire create wire` for creating BoxLang wires (.bx & .bxm)
- Ability to change default argument values for actions [see readme.md](readme.md).
- Ability to view default argument values for actions [see readme.md](readme.md).
- Ability to reset default argument values for actions [see readme.md](readme.md).
- Added CBWIRE module contribution development helpers 

### Changed

- Order of arguments for the `cbwire create wire` action

## [0.1.0] - 2025-05-09

### Added

- Initial Release