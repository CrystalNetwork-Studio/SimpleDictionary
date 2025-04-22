# GitHub Actions Workflows

This directory contains GitHub Actions workflows for the SimpleDictionary project.

## Nightly Build

The `nightly.yml` workflow runs automatically on:
- Every push to the `main` branch
- Every pull request to the `main` branch
- Daily at midnight UTC

This workflow:
1. Checks out the repository
2. Sets up Java (Java 17)
3. Sets up Flutter
4. Installs dependencies
5. Verifies code formatting
6. Runs static analysis
7. Builds release APKs (split per ABI)
8. Uploads the APK files as artifacts

The APK files are available for download from the GitHub Actions workflow run page.

## Release Build

The `release.yml` workflow is triggered manually from the GitHub Actions tab.

To create a new release:
1. Update the version in `pubspec.yaml`
2. Update the `CHANGELOG.md` file with the new version and release notes
3. Commit and push these changes
4. Go to the GitHub Actions tab and select the "Release Build" workflow
5. Click "Run workflow" and select the release type (patch, minor, major)
6. Click "Run workflow" to start the build

This workflow:
1. Extracts the version from `pubspec.yaml`
2. Extracts release notes from `CHANGELOG.md` for the current version
3. Builds release versions of the app (APK)
4. Creates a GitHub Release with the extracted version and release notes
5. Uploads the built artifacts to the release

## CHANGELOG Format

The `CHANGELOG.md` file should follow the [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [0.1.5] - 2025-04-25

### Added
- Feature 1
- Feature 2

### Changed
- Change 1
- Change 2

### Fixed
- Bug fix 1
- Bug fix 2
```

The release workflow will extract all content between the version header (`## [0.1.5]`) and the next version header or the end of the file.
