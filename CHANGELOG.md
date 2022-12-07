# Changelog

All notable changes to this project will be documented in this file.

## [unreleased]

### Bug Fixes

- Get-DendronVault did not handle seed vault entries
- Removed dash as replaceable character

### Documentation

- Updated readme including images

### Features

- Added source module and manifest
- Test for and resolve a workspace root
- Convert a dendron yaml file to a configuration object
- List the vaults in the configuration
- Convert to and from a dendron timestamp
- Get the frontmatter and markdown content of note file
- Generate a dendron compliant id using nanoid.net
- Create a new note
- Add front matter to the given file
- [**breaking**] ContentInfo `Content` property includes all content
- Create objects from wiki style links
- Basic parsing of a GFM-style task
- Added a function to get task notes
- Add a note with task specific frontmatter

### Bugfix

- Dendron.Vault object path should be type string

### Build

- Install new build scripts
- Add git configuration files
- Update gitversion configuration to latest version

### Task

- Added build tools
- Added vscode tasks and test runner
- Remove build submodule tracking
- Remove build scripts
