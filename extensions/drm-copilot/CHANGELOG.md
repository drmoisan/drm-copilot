# Changelog

All notable changes to the drm-copilot extension are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- PoshQC code-coverage population (issue #527): `Invoke-PoshQCTest` derives the measured
  file set from the workspace. Declare coverage roots in `config/poshqc-coverage.json` at
  the workspace root (`{"version": 1, "roots": [...]}`). A `CodeCoverage.Path` list in the
  module's shipped `settings/pester.runsettings.psd1` is now ignored, and the ignore is
  logged. A caller-supplied settings file (`-SettingsPath`) with a non-empty
  `CodeCoverage.Path` is still honored. Without the configuration file, the population
  falls back to the effective test scan folders. Migration: move any coverage paths that
  were added to the shipped settings file into `config/poshqc-coverage.json`.
- PoshQC test coverage (issue #953): the bundled `settings/pester.runsettings.psd1` now sets
  `CodeCoverage.UseBreakpoints = $false`, so `Invoke-PoshQCTest` collects coverage with
  Pester's profiler-based tracer instead of breakpoints. The coverage population and
  thresholds are unchanged; per-file covered-line counts can differ from breakpoint mode.
  The bundled installer minimum is now Pester 5.9.0.
  Pester versions are bounded below Pester 6.0: `Install-PoshQCTool` does not accept an
  installed Pester 6.x, and `Invoke-PoshQCTest` imports Pester with `-MinimumVersion 5.9.0`
  and `-MaximumVersion 5.99.99`. When no installed Pester is in that range, `Invoke-PoshQCTest`
  stops with a message to run `Install-PoshQCTool` instead of loading another version.
- PoshQC sharded test runs (issue #953): `Invoke-PoshQCTest` accepts `-ShardIndex`, `-ShardCount`,
  `-ShardFileListPath`, and `-WriteShardFileList`, and assigns test files to shards by size in bytes.
  New exports: `Get-PoshQCShardSlice`, `New-PoshQCShardManifest`, `Test-PoshQCShardCompleteness`,
  `Test-PoshQCShardTestCount`, `Merge-PoshQCCoverageReport`, and `Get-PoshQCCoverageLineSummary`.
  The merged coverage report carries exact LINE counters and omits METHOD and CLASS figures.

## [0.0.1] - 2026-05-02

### Added

- Initial Marketplace release.
- MCP server provider `drmCopilotMcpProvider` exposing repo automation tools.
- Commands for collecting commit and PR context, managing feature folders,
  promoting potential entries to issues, pushing down Copilot/Codex/Claude
  customizations, running PoshQC, and other repository workflows.
