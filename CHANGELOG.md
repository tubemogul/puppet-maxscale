# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Changed
- Move the changelog to markdown and start using semver
- The Travis tests matrix has been changed to get quicker tests and integrate
  rubocop testing for code quality
- `Gemfile` and `Rakefile` have been refactored

### Fixed
- Code quality cleanup based on rubocop and rubocop-spec standards
- Fixed puppet-lint warnings

### Dropped
- Removed the `CONTRIBUTORS` file. You can get the contributors via the GitHub API

## [1.1.0] - 2016-10-13
###  Added
- Added initial support for osfamily RedHat.
- Upgrade to latest puppet-skeleton version from garethr

### Fixed
- Create directories when maxscale user exists

## [1.0.2] - 2016-08-18
### Changed
- Updating documentation

### Fixed
- Fixing a wrong dependency in the metadata

## [1.0.1] - 2016-08-18
### Added
- Add documentation to guide on the last steps of the process for creating a binlog proxy

### Fixed
- fix some ports in the multi-instance example
- Fix some spec issues appeared with newly used fact on the apt module
- Fixing missing execution rights on the init script
- Fixing `json_pure` dependency problems in the `Gemfile`
- Fix a mistake in the installation part of the documentation

## [1.0.0] - 2016-04-26
### Added
- 1st public version of the module
