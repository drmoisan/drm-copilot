# Changelog

All notable changes to the drm-copilot extension are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Docs MCP tools (issue #1036): `run_docs_check`, `run_docs_inventory`, `run_docs_coverage`,
  `update_docs_ledger`, `generate_docs_reference`, and `validate_docs_artifacts` run the
  workspace's `.claude/lib/docs/Invoke-DocsCommand.ps1 -Json` with `pwsh` 7.4 or later and
  return its envelope unchanged in the `docs` result field. Inputs are validated before launch,
  `update_docs_ledger` is the only tool that can write (only with `write: true`), and the tools
  carry read-only or destructive MCP annotations. Host failures return a code-prefixed `summary`
  such as `DOCS_ENTRY_SCRIPT_MISSING` or `DOCS_PWSH_UNAVAILABLE`.
- Claude core pack skill `/epic-progress-report` (issue #1093): the core pack now carries
  `.claude/skills/epic-progress-report/SKILL.md` and its five bundled PowerShell scripts under
  `.claude/skills/epic-progress-report/scripts/` (the report entry script and its Logic, State,
  Metrics, and Render files). The skill schedules the coordinator's TL;DR and hourly epic
  progress reports, and the script keeps its baseline and samples in
  `.claude/state/epic-progress-<epic-folder>.json`. A destination repository receives the skill
  through the push-down only after the extension is rebuilt and reinstalled.

### Changed

- Claude core pack skill `/epic-progress-report` (issue #1118): the report measures progress
  in typed steps (research, spec, plan, preflight, one execution step per plan task, review,
  pr, ci, merge, main-sync, and integration-pr) instead of checked plan tasks, counts the steps
  each opened remediation cycle adds, and estimates the time remaining as the sum over step
  types of remaining steps times the median measured duration, with stated default durations
  for types that have no sample (`-StepDefaultMinutes` overrides them). Blocked items are
  excluded by recorded checkpoint state. The TL;DR keeps four lines; the velocity, standard
  deviation, and range lines are replaced by a Now line and a per-type table. A new `Item`
  parameter set (`-Issue <n>`) reports a standalone item. The state file is version 2 with a
  duration ledger and per-item tick anchors; version 1 files are migrated. The core pack adds
  four scripts under `.claude/skills/epic-progress-report/scripts/` (Stages, Steps, Durations,
  and Gather). The live stage names the orchestrator records (for example `feature_review`,
  `atomic_execution`, and `S8_create_pr`) map to their step types, a running execution task is
  timed from the later of the stage start and the last plan tick, and item-mode and
  single-feature reports use item and singular wording. A running step without a recorded
  start reads `start not recorded` on the Now line, the `S2_feature_documents` stage maps to
  `spec`, and a merged item's tick anchors are removed from the state file.
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

### Fixed

- Claude and Codex core pack contents (issue #984): the Claude core pack now carries
  `.claude/hooks/enforce-completion-helpers.ps1`, `.claude/agents/pr-author.md`,
  `.claude/hooks/validate-pr-author-output.ps1`, and the four language hooks registered by
  `.claude/settings.json` (`check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`,
  `check-powershell-test-purity.ps1`, and `enforce-powershell-batch-budget.ps1`). The Codex core
  pack now carries `.codex/scripts/post-codex-worktree-session.ps1`.
  `enforce-completion-consistency.ps1` no longer denies edits outside
  `artifacts/orchestration/orchestrator-state.json` when its helper is absent, and it still
  denies checkpoint edits in that case. The discovery artifact gate and both batch-budget hooks
  allow out-of-scope paths when their evaluation-only dependency fails to load, and they still
  deny in-scope paths. Repositories that received the Claude push-down at 1.1.19, 1.1.20, or
  1.1.21 must re-run the Claude push-down to receive the missing files.
- Claude and Codex worktree sessions in Linux dev containers (issue #1003): the setup steps and
  the agent launch were typed into the terminal input stream and could arrive at the shell as one
  concatenated line, which failed with a PowerShell `ParserError`. Both sessions now deliver setup
  and launch as one encoded PowerShell script at process start (`-NoExit -EncodedCommand`) in a
  terminal created with `hideFromUser`, and activate the virtual environment through a runtime
  probe of `.venv/Scripts` and `.venv/bin`. Setup is now fail-fast: it stops at the first failed
  step and does not launch the agent, where previously every line ran regardless of earlier
  failures. Each step prints a progress banner, and the 5-second launch delay is removed.

## [0.0.1] - 2026-05-02

### Added

- Initial Marketplace release.
- MCP server provider `drmCopilotMcpProvider` exposing repo automation tools.
- Commands for collecting commit and PR context, managing feature folders,
  promoting potential entries to issues, pushing down Copilot/Codex/Claude
  customizations, running PoshQC, and other repository workflows.
