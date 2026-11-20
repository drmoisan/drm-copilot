# 2026-07-25-bundled-coverage-path-portability (Spec)

- **Issue:** #409
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-07-25T10-45
- **Status:** Ready for Planning
- **Version:** 1.0
- **Work Mode:** full-bug (this spec is the sole authoritative acceptance-criteria source; no `user-story.md` exists for this feature)

## Context
The MCP server's bundled PoshQC Pester configuration ships this repository's own `CodeCoverage.Path` list. When `mcp__drm-copilot__run_poshqc_test` runs against a different consumer repository, those paths do not exist, and the Pester run fails at RunStart even though test discovery succeeded.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- MCP server version: `@danmoisan/drm-copilot-mcp` 1.0.18
- Command/flags used: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` pointing at the TaskMaster repository
- Data source or fixture: TaskMaster repository checkout (external consumer repo, not drm-copilot)

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The PowerShell test stage of the mandatory toolchain cannot run in any consumer repository through the MCP surface, which blocks orchestration runs in those repositories.


## Repro & Evidence
Steps to Reproduce:
1. Install `@danmoisan/drm-copilot-mcp` 1.0.18 and register it as an MCP server.
2. Open a consumer repository that is not drm-copilot (observed with a repository named TaskMaster) containing PowerShell Pester suites.
3. Invoke `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to that consumer repository root.
4. Observe that Pester discovers the consumer repo's tests (30 tests observed) and then fails during RunStart.

Expected:
`run_poshqc_test` runs the consumer repository's discovered Pester tests to completion. Coverage instrumentation is scoped to files that actually exist in the target workspace; coverage paths that do not exist in the target workspace do not abort the run.

Actual:
The run aborts during Pester RunStart. The bundled coverage configuration at `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (mirrored into the MCP package as `resources/powershell/PoshQC/settings/pester.runsettings.psd1` by `packages/mcp-server/prepack.cjs`) enumerates drm-copilot-specific `CodeCoverage.Path` entries, including `scripts/powershell/Publish-DrmCopilotExtension.ps1`. `Invoke-PoshQCTest` joins each entry to the supplied `-Root` and passes the result to Pester without checking existence, so in TaskMaster every coverage path resolves to a nonexistent file.

Reported error text:

> MCP version 1.0.18 discovers 30 tests but fails during Pester RunStart because its bundled coverage configuration references the nonexistent TaskMaster path `scripts/powershell/Publish-DrmCopilotExtension.ps1`.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: consumer-repo evidence artifact reported by the user at `docs/features/active/2026-07-21-quickfiler-folder-selector-dropdown-400/evidence/regression-testing/coverage-wrapper-poshqc-test-blocker-retry.2026-07-25T03-33.md` (path is inside the TaskMaster checkout, not this repository).


## Scope & Non-Goals
- In scope:
  - Prune nonexistent configured coverage paths inside `Invoke-PoshQCTest` (research option (a)), using the existing injectable `$TestPathExists` seam, at the final resolution site in the coverage-enabled block (`scripts/powershell/PoshQC/PoshQC.Testing.psm1`, around lines 338-347).
  - Log each pruned path individually through the existing `$Logger` seam so pruning is never silent.
  - Disable code coverage for the invocation when pruning removes every configured coverage path (decision SD2), with a single logged explanation, and proceed with the test run.
  - Apply the identical edit to the bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` so the parity contract (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`) continues to pass.
  - Deterministic seam-injected unit tests for the pruning behavior (no temp files, no filesystem dependence).
- Out of scope / non-goals:
  - Research options (b) and (c) are rejected: (b) removes this repository's own coverage list from the canonical gate and breaks its coverage measurement; (c) does not fix the defect standalone (a consumer without a local settings file still aborts).
  - Version bump and Marketplace/npm publish. This fix delivers the corrected source and its mirrored copy; releasing it to consumers is a separate release action (`Invoke-FullRelease.ps1` PR, tag push, CI publish).
  - Changes to `settings/pester.runsettings.psd1` (both copies remain unchanged).
- Explicitly excluded systems, integrations, or datasets:
  - **SD1 (non-normative scope note):** the latent `Run.Path` portability risk — a discovery-time abort when a consumer repository lacks a scan config and a default `Run.Path` entry does not exist (research section Q2) — is excluded from #409. It is a distinct failure mode on a different code path (`Find-File` wildcard branch) that did not occur in the reported reproduction; it will be tracked as a separate issue. No acceptance criterion in this spec covers it.

## Root Cause Analysis
- `scripts/powershell/PoshQC/PoshQC.psm1` line 3 resolves `$script:PesterSettings` to the module-relative `settings/pester.runsettings.psd1`, so the bundled repo-specific settings file is the default for every consumer repository.
- `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (`Invoke-PoshQCTest`, `$ExpandCoveragePaths` and the coverage-enabled block) joins each configured `CodeCoverage.Path` entry to `-Root` with no existence filter and no fallback when the surviving set is empty.
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` locks `settings/pester.runsettings.psd1` to exact text parity between `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`, so the bundled copy cannot simply be given a different, repo-neutral coverage list without addressing that parity contract.
- Files to inspect: `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, the bundled mirrors of both, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.


## Proposed Fix

### Design summary (what changes where):

Approved approach: **research option (a)** — prune nonexistent coverage paths inside `Invoke-PoshQCTest`.

In the coverage-enabled block of `Invoke-PoshQCTest` (`scripts/powershell/PoshQC/PoshQC.Testing.psm1`, lines 338-347), after `$resolvedCoveragePaths` is computed:

1. Filter the resolved set through the existing injectable `$TestPathExists` seam (declared at line 167; the same seam already used by `$EnumerateTests`). Existing paths pass through unchanged; nonexistent paths are removed.
2. Log each pruned path individually, with its resolved value, through the existing `$Logger` seam (lines 256-260). Pruning is never silent.
3. **Empty-surviving-set rule (decision SD2):** if pruning removes every configured coverage path, disable code coverage for that invocation (`$config.CodeCoverage.Enabled = $false`; `$coverageEnabled = $false`), log a single clear explanation, and proceed with the test run. Rationale: leaving `CodeCoverage.Enabled` true with an empty `Path` set makes Pester fall back to instrumenting entire `Run.Path` directories (`Pester.psm1:8567-8588`), which is a different and worse behavior than the defect being fixed. Setting `$coverageEnabled = $false` also naturally skips the coverage-artifact copy step (`PoshQC.Testing.psm1:383`).

Pruning happens once, at the final authoritative resolution site, after `$coverageEnabled` is computed (lines 329-336) and before `$InvokePester` runs (line 380). The earlier `$ExpandCoveragePaths` default seam (lines 215-240) continues to root paths only; a second pruning site is unnecessary because the enabled block re-resolves both rooted and unrooted entries.

### Boundaries and invariants to preserve:

- **Bundled parity:** `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` must remain byte-identical (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
- **No behavior change when all configured paths exist:** in this repository every configured coverage path exists, so the surviving set is identical to today's set and the run — including the coverage summary replay (lines 411-431) — is unchanged.
- **No silent coverage exclusion:** `.claude/rules/general-unit-test.md` prohibits excluding production files from coverage measurement. Silent pruning would be an undetectable coverage exclusion; logging every pruned path keeps removal observable in run output and CI logs.
- **File size cap:** `PoshQC.Testing.psm1` is currently 443 lines; the pruning block adds roughly 15-25 lines, remaining under the 500-line cap.
- **Existing test compatibility:** the existing coverage-enabled-block test (`tests/scripts/powershell/PoshQC/PoshQC.TestingInvokeConfigPaths.Tests.ps1`) injects `-TestPathExists { $true }`, so its configured path survives pruning and its assertions remain valid.

### Dependencies or blocked work:

- None. All seams (`$TestPathExists`, `$Logger`, `$InvokePester`) already exist as injectable scriptblock parameters of `Invoke-PoshQCTest`. No packaging change is needed (`packages/mcp-server/prepack.cjs` already copies the bundled mirror).
- Delivery to the reporting consumer requires a later release action (version bump, tag, npm publish), which is out of scope here.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

Production surface — exactly two files, byte-identical:
1. `scripts/powershell/PoshQC/PoshQC.Testing.psm1`
2. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1`

Test surface — one file in `tests/scripts/powershell/PoshQC/`: either extend `PoshQC.TestingInvokeConfigPaths.Tests.ps1` or add `PoshQC.TestingCoveragePruning.Tests.ps1` following the same module-collision-guard `BeforeAll` pattern; prefer a separate file if the scenarios push the existing file near the 500-line cap.

#### Functions/classes/CLI commands impacted:

- `Invoke-PoshQCTest` (`PoshQC.Testing.psm1`) — coverage-enabled block only. No parameter signature changes; the fix uses existing parameters.
- The MCP tool `run_poshqc_test` and the bundled entry `run-poshqc-test.ps1` are impacted transitively (behavior change in consumer workspaces) with no changes to their own source.

#### Data flow and validation changes:

- Before: every configured `CodeCoverage.Path` entry, joined to `-Root`, is forwarded to Pester without existence checks; one missing path aborts the run at RunStart (`Resolve-CoverageInfo`'s single `try/catch` discards the whole set and the `Write-Error` is terminating under the entry script's global `Stop` preference; `Run.Exit = $true` converts the throw to `exit -1`).
- After: only paths for which `$TestPathExists` returns true are forwarded. `Resolve-CoverageInfo` never sees a nonexistent path. Rooted absolute entries are kept or pruned by the same predicate without re-joining to `-Root`.

#### Error handling and logging updates:

- Each pruned path: one log line naming the resolved path, emitted via the existing `$Logger` seam.
- Empty surviving set: one log line stating that code coverage is disabled for this invocation because no configured coverage path exists under the resolved root.
- No new error types; no catch-all handlers; the run proceeds after pruning or disabling.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the two mirrored production files and the test file. The change is additive and confined to one block.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Input: configured `CodeCoverage.Path` entries from the resolved Pester settings (`pester.runsettings.psd1`, unchanged), plus `-Root`.
- Output to Pester: `CodeCoverage.Path` set equal to the surviving (existing) paths; `CodeCoverage.Enabled` false when the surviving set is empty.
- Log output: one line per pruned path; one line for the disable case.

#### Required configuration keys and defaults:

- None added or changed. `settings/pester.runsettings.psd1` (both copies) is not modified.

#### Backward-compatibility expectations:

- Workspaces where all configured coverage paths exist (this repository): behavior unchanged, measured per-file coverage set identical.
- Workspaces where some or none exist (consumer repositories): the run completes instead of aborting; coverage is scoped to existing paths, or disabled with a logged explanation when none exist.
- `Invoke-PoshQCTest` public parameter surface: unchanged.

#### Performance constraints (latency/throughput/memory):

- One `Test-Path`-class existence check per configured coverage entry (~35 entries) per invocation. Negligible relative to a Pester run; no measurable constraint applies.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - Pester 5.6.1 is the pinned test framework (`PoshQC.psm1:57`); the failure-mechanism line references in this spec are against that version.
  - `Test-Path` and `Resolve-Path` share provider path semantics, so no path Pester could previously resolve is dropped by the pruning predicate (research section 6).
- Constraints (budget, performance, compatibility):
  - PowerShell direct-mode change budget (`.claude/rules/powershell.md`): 2 production files; per-batch cap 3 production + 3 test files. This fix is 2 production + 1 test.
  - 500-line file cap on `PoshQC.Testing.psm1` and the test file.
  - Temp files are strictly prohibited in tests (`.claude/rules/general-unit-test.md`).
- External dependencies (services, libraries, releases):
  - None for the fix. Consumer delivery depends on a later, out-of-scope release (npm publish of `@danmoisan/drm-copilot-mcp` > 1.0.18).

## Data / API / Config Impact
- User-facing or API changes: none to parameter surfaces. Consumer-visible behavior change: `run_poshqc_test` completes in workspaces missing configured coverage paths instead of aborting at RunStart.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): new log lines via the existing `$Logger` seam — one per pruned coverage path, plus one disable notice when the surviving set is empty.
- Compatibility notes (CLI flags, config schemas, versioning): no CLI flag or config schema changes. No version bump in this fix (out of scope; separate release action).

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: `Invoke-PoshQCTest` coverage-path resolution — nonexistent-path pruning, empty-surviving-set behavior, and preservation of existing behavior when all paths exist.
- [x] Integration scenario to retest: run the bundled `run-poshqc-test.ps1` entry point against a workspace root that contains Pester tests but none of the configured coverage paths, and confirm the run completes.
- [x] Manual verification notes: confirm the drm-copilot repository's own coverage numbers are unchanged after the fix, since every configured path exists here.

- Regression tests to add or update:
  - **Fail-before evidence (decision SD3):** a deterministic Pester unit test that drives `Invoke-PoshQCTest` with an injected `$TestPathExists` seam reporting the configured coverage paths as absent, asserting that the pre-fix code forwards nonexistent paths to the injected `$InvokePester` seam. No temp files; no live Pester subprocess. Captured output stored under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/`.
  - New seam-injected Pester tests in `tests/scripts/powershell/PoshQC/` (extend `PoshQC.TestingInvokeConfigPaths.Tests.ps1` or add `PoshQC.TestingCoveragePruning.Tests.ps1`) covering:
    1. All configured paths exist → `$InvokePester` receives the full resolved set; no prune log lines (pass-through preservation).
    2. Mixed set → only existing paths survive; each pruned path is logged with its resolved value.
    3. No path exists → `CodeCoverage.Enabled` is false at `$InvokePester`; the run proceeds (summary still replayed); disable message logged; coverage-copy step not invoked.
    4. Rooted absolute entry → kept or pruned by the same predicate without re-joining to `-Root`.
  - `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (existing, unmodified) verifies the mirror stays byte-identical.
- Unit tests (pytest) for the fixed behavior and boundaries: no new pytest tests; the pytest surface for this fix is the existing parity test. Behavior tests are Pester (the changed code is PowerShell).
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): rooted absolute entries; mixed existing/missing sets; empty surviving set; `CodeCoverage.Enabled = $false` in settings (pruning block never runs, as today); `$config.CodeCoverage` null (existing guard unchanged).
- Error handling and logging verification: tests capture `$Logger` messages in a list and assert each pruned path is named and the disable message appears exactly once in the empty-set scenario.
- Coverage impact and targets for changed lines/modules: `PoshQC.Testing.psm1` is already in the coverage denominator (`pester.runsettings.psd1:97`); the new pruning lines must be covered by the new tests. Branch coverage is not separately measurable for PowerShell in this toolchain (documented limitation). Repo-level thresholds (line >= 85%, branch >= 75% where measured) must hold.
- Toolchain commands to run (format → lint → type-check → test): PoshQC MCP surface per `.claude/rules/powershell.md` — `run_poshqc_format` → `run_poshqc_analyze` → (no type-check stage for PowerShell) → `run_poshqc_test`; plus `pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. Repeat the full loop until all stages pass in a single pass.
- Manual validation steps (if required): none required beyond the evidence comparisons below.

### Evidence plan (canonical locations per `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`)

All evidence resolves under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/<kind>/`:

- `evidence/baseline/` — pre-change `run_poshqc_test` run at the drm-copilot root: replayed coverage summary and a copy of the per-file entries from the tool output `artifacts/pester/powershell-coverage.xml` (the tool's own output location is permitted as tool output; the copy in the evidence tree is the evidence artifact).
- `evidence/qa-gates/` — post-change run of the same command with the same copied artifacts, plus a delta note showing: identical measured-file set, covered-percent equal or better, and zero prune messages in the run log.
- `evidence/regression-testing/` — fail-before unit-test output (SD3), pass-after unit-test output, and the consumer-scenario integration run output (workspace root containing Pester tests but none of the configured coverage paths, run completes).


## Acceptance Criteria
- [x] Nonexistent configured coverage paths are pruned inside `Invoke-PoshQCTest` before Pester is invoked (via the `$TestPathExists` seam in the coverage-enabled block), and existing paths are passed through unchanged.
- [x] Pruning is observable: each pruned path is logged individually through the existing `$Logger` seam, so removal is never silent. Rationale: `.claude/rules/general-unit-test.md` prohibits excluding production files from coverage measurement; silent pruning would be an undetectable coverage exclusion.
- [x] When pruning removes every configured coverage path, code coverage is disabled for that invocation (`CodeCoverage.Enabled` false at the `$InvokePester` boundary) with a logged explanation, and the test run proceeds. Coverage is never handed to Pester as an enabled-but-empty path set, which would trigger whole-directory `Run.Path` instrumentation (`Pester.psm1:8567-8588`).
- [x] Behavior is unchanged when every configured coverage path exists: this repository's measured per-file coverage set is identical before and after the fix, proven by comparing the per-file entries of `artifacts/pester/powershell-coverage.xml` between a baseline run (copied to `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/baseline/`) and a post-change run (copied to `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/qa-gates/`), with zero prune messages in the post-change run log.
- [x] The bundled mirror `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` is byte-identical to `scripts/powershell/PoshQC/PoshQC.Testing.psm1`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes.
- [x] Unit tests exercise the pruning behavior deterministically via the injectable seams (`$TestPathExists`, `$Logger`, `$InvokePester`), covering the four required scenarios (all-exist pass-through, mixed set, empty surviving set, rooted absolute entry), with no temp files and no filesystem dependence; fail-before evidence per decision SD3 is captured under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/`.
- [x] The consumer-repository scenario completes: a Pester run against a workspace root that contains Pester tests but none of the configured coverage paths finishes test execution instead of aborting at RunStart, with output captured under `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/evidence/regression-testing/`.
- [x] Full toolchain pass completed for the changed surfaces (`run_poshqc_format` → `run_poshqc_analyze` → `run_poshqc_test`, plus the parity pytest), all stages clean in a single pass.

## Risks & Mitigations
- Technical or operational risks:
  - Accidental pruning of an existing path in this repository (a coverage-measurement reduction). Mitigation: pruning uses the same provider path semantics as Pester's own `Resolve-Path`; every prune is logged; the baseline/post per-file comparison (acceptance criterion 4) detects any drop.
  - Divergence between the two mirrored copies. Mitigation: `test_poshqc_bundled_parity.py` fails CI on any byte difference (acceptance criterion 5).
  - Regression in the existing coverage-enabled-block tests. Mitigation: the existing test injects `-TestPathExists { $true }`, so its assertions are unaffected; the full PoshQC test suite runs in the toolchain loop.
- Mitigations and rollbacks: the change is additive and confined to one block in one function (mirrored); rollback is a revert of the two production files and the test file.

## Rollout & Follow-up
- Release/rollout steps: none in this fix. Delivery to consumers requires the separate release action (version-bump PR via `Invoke-FullRelease.ps1`, tag push, CI npm publish) — explicitly out of scope for #409.
- Post-fix monitoring or clean-up tasks:
  - File a separate issue for the latent `Run.Path` discovery-time portability risk (SD1, research section Q2).
  - If the integration reproduction creates `TestResult`/coverage output directories under the chosen in-repo root, remove them after capturing evidence.
- Links: issue #409 (https://github.com/drmoisan/drm-copilot/issues/409), branch `bug/bundled-coverage-path-portability-409`, research artifact `docs/features/active/2026-07-25-bundled-coverage-path-portability-409/research/2026-07-25T10-20-bundled-coverage-path-portability-409-research.md`, field evidence reference in `issue.md`.
