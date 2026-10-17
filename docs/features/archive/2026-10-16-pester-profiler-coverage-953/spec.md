# 2026-10-16-pester-profiler-coverage (Spec)

- **Issue:** #953
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16
- **Status:** Ready for planning
- **Version:** 0.2
- **Work Mode:** full-bug (acceptance criteria source: this file only; `user-story.md` is intentionally absent)
- **Research:** `docs/features/active/2026-10-16-pester-profiler-coverage-953/research/research.2026-10-16T04-28.md` (cited below as "research §N")

## Context

The Windows `poshqc / PowerShell QC` job sets the length of every CI run. In baseline run 38846579572 the job took 18.6 minutes, of which the `Test PowerShell` step (`Invoke-PoshQCTest`) took 15.5 minutes and the `Analyze PowerShell` step took 2.1 minutes (`issue.md`). Every other CI job finishes within about 6 minutes. The step runs the full repository Pester suite with breakpoint-based code coverage.

Environment:
- OS/version: GitHub Actions windows-latest (runner image ships Pester 3.4.0 and 5.9.0, research §2.1); local Windows 11
- Python version: n/a
- Command/flags used: `Invoke-PoshQCTest -Root <workspace>` in `.github/workflows/_poshqc.yml` (research §1.2)
- Data source or fixture: full repository Pester suite

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Problem Statement

Every pull request waits on the Windows PowerShell QC job, and that job is dominated by one step that spends most of its time in breakpoint-based coverage instrumentation. Coverage enforcement must stay intact while the step is shortened. In addition, the Pester minimum is declared as 5.6.1 in the module installer and supporting files, while CI runs 5.9.0, so local and CI behavior rest on different declared minimums.

## Repro & Evidence

Steps to Reproduce:
1. Open any PR against `main`.
2. Inspect the step timings of the `poshqc / PowerShell QC` job.
3. Observe that `Test PowerShell` takes about 15.5 minutes, while every other job finishes within about 6 minutes.

Expected:
The Windows Pester step finishes in a time comparable to the other CI jobs, with no reduction in coverage enforcement.

Actual:
The step takes about 15.5 minutes, so every CI run takes 14 to 19 minutes.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: run 38846579572 step timings: Analyze PowerShell 2.1m, Test PowerShell 15.5m.

Baseline figures are taken from `issue.md`; research §7 records that they were not re-read in the research session. The executor re-reads run 38846579572 as P0 evidence (see FR-08).

## Root Cause Analysis

- Coverage runs in Pester breakpoint mode. The shipped `pester.runsettings.psd1` (both copies) has no `UseBreakpoints` key, so Pester 5's default `UseBreakpoints = $true` applies (research §1.1). `Invoke-PoshQCTest` never sets the key (research §1.1, `PoshQC.Testing.psm1:154-460`).
- Breakpoint mode sets one `Set-PSBreakpoint` per command in the coverage population, which is markedly slower than profiler (tracer) mode. Profiler mode (`UseBreakpoints = $false`) has existed since Pester 5.3.0 and requires Pester 5.4 or later for this repository's purposes (research §2.2, §3.2).
- Both modes build the same command list (`Get-CoverageBreakpoints`), so the coverage denominator is identical; only hit collection differs (research §3.2). Per-file hit counts may shift where the executing scriptblock's file string differs from the coverage path string or where breakpoint binding behaved differently.
- Pin drift: the installer pin in `PoshQC.psm1:57` is a floor of 5.6.1; CI runs 5.9.0 because the runner image ships it (research §2.1).

## Goals

- G1: Shorten the CI `Test PowerShell` step by switching coverage to profiler mode through shipped configuration data.
- G2: Keep coverage enforcement unchanged: same population, same denominator, same thresholds, no production file excluded.
- G3: Reconcile the declared Pester minimum to 5.9.0 at every site listed in research §2.3, and bound Pester below 6.0 at the sites listed in AC-16 (D8).
- G4: Record before/after CI timings and per-file coverage changes as evidence.
- G5: If the step remains above the sharding trigger, shard it inside `_poshqc.yml` job bodies without changing the reported check name.
- G6: Record the profiler-mode `ci` values of the #936 attribution-gap lines.

## Scope & Non-Goals

- In scope:
  - `CodeCoverage.UseBreakpoints = $false` in both runsettings copies.
  - Pester minimum 5.9.0 at the research §2.3 sites and in the tests that read the committed host-tools manifest.
  - A Pester major-version ceiling below 6.0 at the sites listed in AC-16 (D8), and the existing test fixtures that inject a present module above that ceiling.
  - A new regression test for the runsettings key, the installer version, and the Pester version ceiling.
  - CI timing and coverage evidence under the feature folder.
  - The conditional sharding phase (FR-09), executed only if its trigger fires.
- Out of scope / non-goals:
  - Editing `.github/workflows/ci.yml` or any workflow `on:` block (owned by concurrent item #952).
  - Adding a failing CI PowerShell coverage threshold on any path (D3).
  - Setting `UseBreakpoints` in code inside `Invoke-PoshQCTest`, or passing a CI-only settings file (rejected in research §6.2).
  - A Pester version ceiling in `scripts/host-tools.manifest.json` or `scripts/dev-tools/HostVerification.psm1`. The major-version ceiling below 6.0 itself (optional hardening in research §2.2) is no longer deferred: decision D8 brings it into scope at the sites listed in AC-16.
  - Editing the #936 test files or their headers (D4).
  - Publishing the MCP package; the bundled-copy change reaches MCP consumers only on the next package release (research §9).
- Explicitly excluded systems, integrations, or datasets:
  - `.claude/rules/**` and `.github/instructions/**` (policy files are read-only).
  - `.devcontainer/local/Dockerfile`, `.devcontainer/codespaces/Dockerfile`, `.devcontainer/TROUBLESHOOTING.md` (declare a 5.0.0 floor; research §2.3 "Not changed").
  - Test fixtures that build their own synthetic manifest or mock module versions without reading the committed manifest (research §2.3, N2 exclusion rules).

## Functional Requirements

| ID | Requirement | Research source |
|---|---|---|
| FR-01 (R1, speed) | Add `UseBreakpoints = $false` to the `CodeCoverage` block of `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, with a comment citing #953. The two files remain text-identical. All local runners (`scripts/dev-tools/run-pester.ps1`, `scripts/dev-tools/run-poshqc-suite.ps1`, `scripts/dev_tools/fix_all_branches.py`, `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1`) inherit the setting without modification. | §1.3, §6.2, §10 R1 |
| FR-02 (R2, enforcement unchanged) | `Enabled`, `OutputFormat`, `OutputPath`, the coverage population source (`config/poshqc-coverage.json`), and `CoveragePercentTarget` are unchanged. No production file leaves the coverage population. The repo-wide LINE total (missed + covered) in the PR-head coverage artifact equals the baseline total. | §3.3, §10 R2 |
| FR-03 (R3, thresholds) | Repo-wide LINE coverage computed from the PR-head CI `powershell-coverage.xml` (sum of `//counter[@type="LINE"]` at report level, as in `validate-feature-review-coverage-metrics.ps1`) is >= 85%. Every `sourcefile` whose covered LINE count differs between the baseline and PR-head artifacts is listed with before and after covered/missed values. No threshold is lowered. | §3.1, §3.3, §10 R3 |
| FR-04 (R4, pin) | Replace Pester `5.6.1` with `5.9.0` at the sites in research §2.3 (enumerated in "Files in scope", items 3-11), and in every test that asserts against the committed `scripts/host-tools.manifest.json`. | §2.2, §2.3, §10 R4 |
| FR-05 (regression test) | Add `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1`. It loads the shipped `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` with `Import-PowerShellDataFile`; asserts `CodeCoverage.UseBreakpoints -eq $false`, `CodeCoverage.Enabled -eq $true`, and `CodeCoverage.OutputFormat -eq 'CoverageGutters'`; builds `New-PesterConfiguration -Hashtable` from the loaded table and asserts `CodeCoverage.UseBreakpoints.Value -eq $false`. A second case invokes `Install-PoshQCTool` with injected `-SetTls`, `-GetRepository`, `-FindModule`, `-InstallModule`, and `-Logger` seams (no real install, no network) and asserts that the recorded `InstallModule` call for `Pester` carries version `5.9.0`. Both cases fail on the pre-fix tree and pass after the fix. The test creates no temporary files; reading a checked-in file follows the precedent in `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1:17-18`. | §4 (gap), §10 item 13, §11 |
| FR-06 (R6, #936 observation) | From the PR-head CI `powershell-coverage.xml`, record the `ci` and `mi` attributes of `<line nr="41">` in the `enforce-orchestration-preimplementation-gate-modes.ps1` sourcefile under `.codex/hooks/`, and of `<line nr="206">` and `<line nr="207">` in the `enforce-orchestration-preimplementation-gate-epic-scope.ps1` sourcefile under `.codex/hooks/`. Record the same values from the baseline artifact where present. No #936-owned test file is edited. | §5, §10 R6 |
| FR-07 (changelog) | Add an `[Unreleased]` entry to `extensions/drm-copilot/CHANGELOG.md` stating that the bundled PoshQC runsettings now use profiler-based coverage and that the bundled installer minimum is Pester 5.9.0. | §9 (bundle/MCP lag) |
| FR-08 (timing) | Record the baseline and PR-head CI timings per research §7 (see "Timing Requirements"). | §7 |
| FR-09 (R5, conditional sharding) | Evaluate the sharding trigger on the PR-head run and either execute or close the sharding phase (see "Conditional Sharding Requirement"). | §6.3, §10 R5 |
| FR-10 (README) | Update the Pester version text and add a profiler-mode note to the Pester settings bullet in both `README.md` copies; the two copies remain identical. | §10 items 5-6, §9 (Windows PowerShell 5.1 note) |

## Timing Requirements

- Baseline: CI run `38846579572`; step `Test PowerShell` 15.5 minutes; job `poshqc / PowerShell QC` 18.6 minutes (`issue.md`). The executor re-reads the run before any edit:
  - Step: `gh run view 38846579572 --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | .steps[] | select(.name=="Test PowerShell") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))'`
  - Job: `gh run view 38846579572 --json jobs --jq '.jobs[] | select(.name=="poshqc / PowerShell QC") | ((.completedAt|fromdateiso8601) - (.startedAt|fromdateiso8601))'`
  - Store the raw `gh run view 38846579572 --json jobs` output and the computed seconds under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/baseline/`.
- After: the same two commands against the PR-head CI run id. Store the raw JSON and computed seconds under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`. This is a CI-dependent acceptance criterion.
- The first `main` run after merge is recorded as a follow-up observation (research §7) and is not an acceptance criterion of this item.
- `gh --jq` uses gh's embedded jq; no standalone `jq` binary is required (research §6.3).
- No fixed speedup target is set for the primary path; the sharding trigger below is the only numeric decision point.

## Conditional Sharding Requirement

- Trigger (mechanical): let `T` be the `Test PowerShell` step duration in seconds on the PR-head CI run, computed as `completedAt` minus `startedAt` from `gh run view <pr-head-run-id> --json jobs` with the step command above. The trigger fires if and only if `T > 480`.
- Evidence: record the raw JSON, the computed `T`, and the decision (`TRIGGERED` or `NOT TRIGGERED`) under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/qa-gates/`.
- If NOT TRIGGERED: record `T`, mark the sharding phase closed as not triggered, and write none of the sharding-only files.
- If TRIGGERED (design per research §6.3, constrained by D3):
  - Edits to `.github/workflows/_poshqc.yml` are limited to job and step bodies; lines 1-5 (`name:` and `on:`) are unchanged.
  - A static job runs checkout, install, Format, and Analyze.
  - A matrix shard job (`strategy.fail-fast: false`) runs `Invoke-PoshQCTest` with new `-ShardIndex`/`-ShardCount` parameters and uploads per-shard artifacts with unique names and `if: always()`.
  - The job with id `poshqc` and name `PowerShell QC` is retained so the reported check name remains `poshqc / PowerShell QC`. It depends on the static and shard jobs, downloads the shard artifacts, merges coverage at LINE granularity into `artifacts/pester/powershell-coverage.xml` (per `sourcefile`/`line nr`: `ci = max(ci)`, `mi = (mi + ci) - max(ci)`, counters recomputed bottom-up), writes the Koverage copy, and uploads `poshqc-test-results`.
  - Completeness guard: the merge job fails if the union of shard test-file lists is not equal to the full sorted discovery list, or if the sum of shard JUnit `tests` counts differs from the unsharded discovery count.
  - The merge job reports repo-wide LINE coverage in the job log. It adds no failing coverage threshold (D3); threshold enforcement remains review-time.
  - Every shard measures the full `config/poshqc-coverage.json` population, so merged denominators equal the unsharded denominator.
  - New logic lives in new small files (a shard selector and a coverage-merge pure function), mirrored into the bundle and added to `POSHQC_PARITY_PATHS` and the `PoshQC.psm1` load list. `PoshQC.Testing.psm1` receives parameter plumbing only and stays under 500 lines.
  - Unit tests for the selector and merge function use in-memory XML strings and create no temporary files; `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1` is updated for the new job set.
  - After the sharded workflow runs on the PR head, re-record the timing evidence and the FR-02/FR-03 coverage evidence from the merged artifact.

## Proposed Fix

### Design summary (what changes where):

Data-only switch to profiler coverage in both runsettings copies (research §6.2), Pester minimum reconciled to 5.9.0 (research §2.3), a Pester major-version ceiling below 6.0 (D8), one new regression test, a CHANGELOG entry, and CI evidence. No workflow change is needed for the speedup because the workflow uses module defaults; the only primary-path workflow edit is the version arguments of the Linux job `Import-Module Pester` line at `_poshqc.yml:73` (`-MinimumVersion 5.9.0 -MaximumVersion 5.99.99`).

### Boundaries and invariants to preserve:

- Bundled-parity: the files in `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` `POSHQC_PARITY_PATHS` remain text-identical between `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/` (research §1.4).
- Coverage population, denominator, and thresholds unchanged (FR-02, FR-03).
- Check name `poshqc / PowerShell QC` unchanged; `ci.yml` and every `on:` block untouched.
- No file over 500 lines.

### Dependencies or blocked work:

- Concurrent item #952 owns `.github/workflows/ci.yml` and all workflow triggers.
- Item #936 owns the attribution-gap test files; this item only reports observations.
- CI-dependent criteria require the PR to exist and CI to run on the PR head.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

See "Files in Scope".

#### Functions/classes/CLI commands impacted:

- `Invoke-PoshQCTest` coverage mode changes through loaded settings only. Its only primary-path code change is the default `EnsureModule` seam, which imports Pester with `-MaximumVersion 5.99.99` (D8).
- `Install-PoshQCTool` requested Pester version changes from 5.6.1 to 5.9.0, and its present and post-install checks accept only installed Pester versions below 6.0.0 (data in `$requiredModules`, `UpperBound`; D8).
- `HostBootstrap` Pester install via `scripts/host-tools.manifest.json` `minimumVersion` (drives `-RequiredVersion`, research §2.3).

#### Data flow and validation changes:

None on the primary path beyond the configuration value and the Pester version range (D8). Coverage XML format (CoverageGutters, JaCoCo-structured) is unchanged.

#### Error handling and logging updates:

None. If a profiler-mode run fails in report generation with a duplicate-key error, inspect `Get-CoverageReport` `Hashtable.Add` on `BpLine:BpColumn` keys first (research §3.2 source observation).

#### Rollback/feature-flag considerations (if applicable):

Rollback is removal of the `UseBreakpoints = $false` line from both runsettings copies (research §9). The pin change is independent and need not be reverted.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Input: `pester.runsettings.psd1` `CodeCoverage.UseBreakpoints` (boolean).
- Output: unchanged artifact set `artifacts/pester/pester-junit.xml`, `powershell-coverage.xml`, `powershell-coverage.koverage.xml`.

#### Required configuration keys and defaults:

- `CodeCoverage.UseBreakpoints = $false` (new explicit key; Pester 5 default is `$true`).
- Pester minimum `5.9.0`, with a ceiling below 6.0 (D8): `UpperBound = '6.0.0'` (exclusive) in installed-version filters and `-MaximumVersion 5.99.99` on `Import-Module`.

#### Backward-compatibility expectations:

- A caller that passes `-SettingsPath` keeps full control of the mode (research §6.2).
- MCP consumers keep breakpoint mode until the package is republished (research §9).

#### Performance constraints (latency/throughput/memory):

See "Timing Requirements" and "Conditional Sharding Requirement".

## Files in Scope

### Primary path (written by this item)

1. `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
2. `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`
3. `scripts/powershell/PoshQC/PoshQC.psm1` (the `$requiredModules` block at lines 55-58, with the line 57 pin, plus the version filters at lines 61 and 74: pin, ceiling, and one inserted comment line; D8)
4. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1` (identical to item 3)
5. `scripts/powershell/PoshQC/README.md` (line 16 pin and ceiling text, and profiler-mode note)
6. `extensions/drm-copilot/resources/powershell/PoshQC/README.md` (identical)
7. `.github/workflows/_poshqc.yml` (line 73 `Import-Module Pester` version arguments only, `-MinimumVersion` and `-MaximumVersion`; job body)
8. `scripts/host-tools.manifest.json` (line 15)
9. `.devcontainer/post-create.sh` (line 246 pin and ceiling, line 262 version filter)
10. `.github/codex/codex-web-setup.sh` (line 226 pin and ceiling, line 231 version filter)
11. `tests/scripts/host-tools.manifest.Tests.ps1` (Pester 5.6.1 test name, assertion, and mocked installed version)
12. `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` (line 132, context `committed manifest`, test `AC07-DRYRUN-COMMITTED-MANIFEST`: expected text `Pester 5.6.1` becomes `Pester 5.9.0`)
13. `extensions/drm-copilot/CHANGELOG.md` (`[Unreleased]` entry)
14. `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` (new regression test)
15. Evidence under `docs/features/active/2026-10-16-pester-profiler-coverage-953/evidence/` (`baseline/`, `qa-gates/`, `regression-testing/`)
16. `scripts/powershell/PoshQC/PoshQC.Testing.psm1` (default `EnsureModule` seam at lines 163-169 and its call at line 305; D8)
17. `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.Testing.psm1` (identical to item 16)
18. `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` (lines 118 and 135: present-module fixture version `9.9.9` becomes `5.9.5`; D8)
19. `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1` (lines 46, 58, and 59: the same fixture change and its expected log text; D8)
20. `tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1` (new coverage test for `PoshQC.psm1`; orchestrator decision D6, recorded in the plan)

Items 16-20 are not in research §2.3 or §10. Items 16-19 follow from D8: the import ceiling is set in the default `EnsureModule` seam, and the existing fixtures inject a present module at `9.9.9`, which is above the 6.0.0 ceiling and would make the install seam and its post-install check run. Item 20 follows from orchestrator decision D6, which raises the per-file LINE coverage of the modified `PoshQC.psm1` toward the 85% per-file gate for modified files.

Spec-time correction to research: item 12 is not in research §2.3 or §10. Research N2 excluded `HostBootstrap.Invoke.Tests.ps1` as a synthetic-manifest fixture, but its `committed manifest` context reads `scripts/host-tools.manifest.json` (line 117) and asserts `Pester 5.6.1` at line 132; that assertion fails once the manifest says 5.9.0. Because the research N2 cross-check covered only `tests/scripts/host-tools.manifest.Tests.ps1`, the N2 family is not exhaustive. This spec therefore states no count of affected test lines; completeness of the test-side pin change is verified by the full PoshQC test run (AC-07) rather than by a fixed count.

### Additional files written only if the sharding trigger fires

Sharding-only files (the files that AC-11 requires to be unchanged when the trigger does not fire):

- `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`
- New PoshQC sub-module(s) for the shard selector and coverage merge, in both `scripts/powershell/PoshQC/` and `extensions/drm-copilot/resources/powershell/PoshQC/`
- `scripts/powershell/PoshQC/PoshQC.psd1` and its bundled copy, only if the new sub-module must be declared there
- `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` (`POSHQC_PARITY_PATHS`)
- New unit tests under `tests/scripts/powershell/PoshQC/` for the selector and merge functions

Primary-path files that receive additional edits on the sharding path (they are not sharding-only files): `.github/workflows/_poshqc.yml` (item 7; job and step bodies), `scripts/powershell/PoshQC/PoshQC.psm1` and its bundled copy (items 3-4; sub-module load list), and `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and its bundled copy (items 16-17; shard parameters only).

## Assumptions, Constraints, Dependencies

- Assumptions (environment, data, access):
  - The windows-latest image continues to ship Pester 5.9.0, so `Install-PoshQCTools` installs nothing in CI (research §2.1).
  - The executor has an execution route that permits `pwsh` and `gh` and an authenticated `gh` (research "Automation Feasibility").
  - The baseline run 38846579572 `poshqc-test-results` artifact is retrievable with `gh run download 38846579572 -n poshqc-test-results`. If it has expired, the baseline coverage artifact is taken from the most recent successful `main` CI run at or before the branch base commit, and that run id is recorded in the evidence.
- Constraints (budget, performance, compatibility):
  - No production file excluded from coverage; no threshold lowered; denominator unchanged.
  - No edit to `.github/workflows/ci.yml` or any `on:` block; no policy file edit.
  - No file over 500 lines; tests create no temporary files.
- External dependencies (services, libraries, releases):
  - Pester 5.9.0 profiler coverage (`UseBreakpoints = $false`, labeled experimental in v5 docs; research §3.2).
  - GitHub Actions and `gh` CLI for timing and artifact retrieval.

## Data / API / Config Impact

- User-facing or API changes: none to cmdlet signatures on the primary path. Sharding path adds `-ShardIndex`/`-ShardCount` to `Invoke-PoshQCTest`.
- Data or migration considerations: per-file covered counts may shift; every shift is documented (FR-03).
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): runsettings gains one key; Pester minimum raised to 5.9.0 with a ceiling below 6.0 (D8), so an installed Pester 6.x satisfies neither `Install-PoshQCTool` nor the `Invoke-PoshQCTest` import; bundled change reaches MCP consumers on the next package release.

## Test Strategy

Seeded from issue:

- [x] Unit coverage areas: the PoshQC module configuration tests, and any test that pins the Pester configuration.
- [x] Integration scenario to retest: full suite under profiler mode with the coverage thresholds evaluated.
- [x] Manual verification notes: record the CI step and job times before and after. If the step is still above about 8 minutes, shard it across a matrix and merge the coverage reports.

- Regression tests to add or update: `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` (FR-05); fail-before output stored under `evidence/regression-testing/` before the fix, pass-after output after the fix.
- Unit tests (Pester) for the fixed behavior and boundaries: the regression test, including the D8 ceiling cases named in AC-16; updated `tests/scripts/host-tools.manifest.Tests.ps1` and `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1`; the D8 fixture updates in `tests/scripts/powershell/PoshQC/PoshQC.Tests.ps1` and `tests/scripts/powershell/PoshQC/PoshQC.EntryPoints.Tests.ps1`; and the new `tests/scripts/powershell/PoshQC/PoshQC.ModuleCoverage.Tests.ps1` (D6).
- Edge cases and negative scenarios: `Install-PoshQCTool` case where `FindModule` first returns no qualifying version, so the install seam is invoked; assertion on the exact version argument; `Install-PoshQCTool` case where only Pester 6.0.0 is installed, so the install seam still receives 5.9.0 (D8).
- Error handling and logging verification: none added.
- Coverage impact and targets for changed lines/modules: repo-wide LINE >= 85% on the PR-head artifact; denominator equal to baseline; per-file diff documented.
- Toolchain commands to run: self-hosted PoshQC `Invoke-PoshQCFormat`, `Invoke-PoshQCAnalyze`, `Invoke-PoshQCTest` (import `scripts/powershell/PoshQC/PoshQC.psd1` directly, not the MCP route; research §8); `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; actionlint on `_poshqc.yml` if available.
- Existing suites to re-run (research §11): `tests/scripts/powershell/PoshQC/`, `tests/scripts/workflows/PoshQcWorkflow.Tests.ps1`, `tests/scripts/host-tools.manifest.Tests.ps1`, the HostBootstrap and HostVerification suites.
- Optional local sampled timing comparison (research §8): scratch settings files in the session scratchpad only; the authoritative comparison is the CI artifact.

## Acceptance Criteria

- [x] AC-01: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` each contain `UseBreakpoints = $false` inside the `CodeCoverage` block, and `Import-PowerShellDataFile` on each returns `CodeCoverage.UseBreakpoints -eq $false` with `Enabled`, `OutputFormat`, `OutputPath`, and `CoveragePercentTarget` unchanged from the base commit.
- [x] AC-02: `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` exits 0.
- [x] AC-03: `tests/scripts/powershell/PoshQC/PoshQC.RunSettings.Tests.ps1` exists, asserts `CodeCoverage.UseBreakpoints.Value -eq $false` on a configuration built with `New-PesterConfiguration -Hashtable` from the shipped runsettings, and asserts that `Install-PoshQCTool` passes version `5.9.0` for `Pester` to the injected `-InstallModule` seam; evidence under `evidence/regression-testing/` shows it failing on the pre-fix tree and passing after the fix; the test creates no temporary files.
- [x] AC-04: Pester `5.6.1` is replaced by `5.9.0` at each research §2.3 site: `scripts/powershell/PoshQC/PoshQC.psm1`, `extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1`, `scripts/powershell/PoshQC/README.md`, `extensions/drm-copilot/resources/powershell/PoshQC/README.md`, `.github/workflows/_poshqc.yml` (Linux job `Import-Module Pester -MinimumVersion`), `scripts/host-tools.manifest.json`, `.devcontainer/post-create.sh`, and `.github/codex/codex-web-setup.sh`; a search for `5.6.1` in those files returns no match.
- [x] AC-05: `tests/scripts/host-tools.manifest.Tests.ps1` and `tests/scripts/dev-tools/HostBootstrap.Invoke.Tests.ps1` contain no `5.6.1` expectation tied to the committed manifest, and both files pass under `Invoke-Pester`.
- [x] AC-06: `extensions/drm-copilot/CHANGELOG.md` has an `[Unreleased]` entry naming profiler-based coverage and the Pester 5.9.0 minimum.
- [x] AC-07: The self-hosted PoshQC toolchain passes in a single pass on the branch: `Invoke-PoshQCFormat` produces no diff, `Invoke-PoshQCAnalyze` reports zero findings, and `Invoke-PoshQCTest` reports zero failed tests; outputs stored under `evidence/qa-gates/`.
- [ ] AC-08 (CI-dependent): The repo-wide LINE total (missed + covered) in the PR-head CI `powershell-coverage.xml` equals the baseline artifact's total, no `sourcefile` present in the baseline is absent from the PR-head report, and repo-wide LINE coverage on the PR-head artifact is >= 85%.
- [ ] AC-09 (CI-dependent): A per-file table under `evidence/qa-gates/` lists every `sourcefile` whose covered LINE count differs between the baseline and PR-head artifacts, with before and after covered and missed values, and states the comparison method; if no file differs, the table records that result.
- [ ] AC-10 (CI-dependent): Raw `gh run view --json jobs` output and computed seconds for the `Test PowerShell` step and the `poshqc / PowerShell QC` job are recorded for baseline run 38846579572 under `evidence/baseline/` and for the PR-head run under `evidence/qa-gates/`.
- [ ] AC-11 (CI-dependent): The sharding trigger value `T` (PR-head `Test PowerShell` step seconds) and the decision are recorded; if `T > 480` the sharding phase is implemented as specified in "Conditional Sharding Requirement" with the check name `poshqc / PowerShell QC` unchanged, a passing completeness guard, and no failing coverage threshold added; if `T <= 480` the phase is recorded as closed, not triggered, and no sharding-only file is changed.
- [ ] AC-12 (CI-dependent): The `ci` and `mi` values of `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` line 41 and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` lines 206 and 207 from the PR-head coverage artifact are recorded under `evidence/qa-gates/`, alongside the baseline values where present, and no #936-owned test file is modified.
- [x] AC-13: `git diff --name-only origin/main...HEAD` lists no change to `.github/workflows/ci.yml`, and no `on:` block in any `.github/workflows/*.yml` file differs from `origin/main`.
- [x] AC-14: `git diff --name-only origin/main...HEAD` lists no path under `.claude/rules/` or `.github/instructions/`.
- [x] AC-15: No production, test, or reusable script file changed or added on the branch exceeds 500 lines.
- [x] AC-16: A Pester major-version ceiling below 6.0 accompanies the 5.9.0 minimum (D8): `Install-PoshQCTool` in both `PoshQC.psm1` copies and the present-checks in `.devcontainer/post-create.sh` and `.github/codex/codex-web-setup.sh` accept only installed Pester versions >= 5.9.0 and < 6.0.0; the default `EnsureModule` seam of `Invoke-PoshQCTest` in both `PoshQC.Testing.psm1` copies and the `_poshqc.yml` Linux job import Pester with `-MaximumVersion 5.99.99`; both `README.md` copies and the CHANGELOG `[Unreleased]` entry state the ceiling; the `PoshQC.RunSettings.Tests.ps1` cases `RS05-INSTALLER-PESTER-CEILING-BELOW-6`, `RS06-TEST-IMPORT-PESTER-MAXIMUM`, and `RS07-WORKFLOW-LINUX-PESTER-RANGE` fail on the pre-fix tree and pass after the fix, with evidence under `evidence/regression-testing/`; the tests create no temporary files.

CI-dependent criteria: AC-08, AC-09, AC-10, AC-11, AC-12. They remain unchecked until CI has run on the PR head and are checked off by the item's orchestrator run at S9 per the acceptance-criteria-tracking skill.

## Risks & Mitigations

| Risk | Assessment (research §9) | Mitigation |
|---|---|---|
| Windows PowerShell 5.1 | Tracer patches by major version; CI uses pwsh 7.x; many suites require 7.0. | No action; README note (FR-10). |
| Linux hook job | Coverage disabled there; only the `Import-Module Pester` version arguments change (`-MinimumVersion 5.9.0 -MaximumVersion 5.99.99`). | `PoshQcWorkflow.Tests.ps1` continues to pass (AC-07); `RS07-WORKFLOW-LINUX-PESTER-RANGE` asserts the range (AC-16). |
| Experimental flag in Pester 5 | `UseBreakpoints = $false` is labeled experimental in v5 docs; default in v6. | Per-file diff gate (AC-09); one-key rollback in two files. |
| Tracer interaction with tests | Tracer uses `Set-PSDebug -Trace 1`; no test calls `Set-PSDebug`, `Set-PSBreakpoint`, or real nested `Invoke-Pester`. | Re-check if the CI run shows tracer errors. |
| Per-file coverage shift | Hits can differ by path string or breakpoint binding (research §3.2). | Per-file LINE diff of every sourcefile (AC-09); denominator equality (AC-08). |
| Report-generation duplicate key | `Get-CoverageReport` uses `Hashtable.Add` without a duplicate guard (source observation, not a confirmed defect). | First place to inspect on such a failure. |
| Pester 6 on a future image | Without a ceiling, floor-only install and highest-version import would select Pester 6 silently. | Ceiling below 6.0 at the AC-16 sites (D8). `scripts/dev-tools/HostVerification.psm1` still accepts an installed Pester 6.x (residual, candidate follow-up; non-goal). |
| File-size limit | Primary fix adds one line per runsettings copy and one comment line to `PoshQC.Testing.psm1` (D8); sharding would pressure `PoshQC.Testing.psm1`. | New logic in new small files (AC-15). |
| Concurrent item #952 | Owns `ci.yml` and `on:` blocks. | Edits limited to `_poshqc.yml` job/step bodies (AC-13). |
| Bundle/MCP lag | MCP consumers keep breakpoint mode until republish. | CHANGELOG entry (AC-06). |
| Baseline artifact expiry | Run 38846579572 artifacts may be unavailable. | Fallback baseline run defined in "Assumptions". |
| Research N2 incompleteness | A committed-manifest test outside N2 asserts 5.6.1. | Added to scope (item 12); full-suite pass (AC-07) is the completeness check. |

## Decision Record

- D1: Reconcile the Pester minimum to 5.9.0 at every research §2.3 site (both `PoshQC.psm1` installer pins, both README copies, the `_poshqc.yml` Linux job `Import-Module Pester -MinimumVersion` line, `scripts/host-tools.manifest.json`, the `tests/scripts/host-tools.manifest.Tests.ps1` assertions and mock, `.devcontainer/post-create.sh`, `.github/codex/codex-web-setup.sh`). Profiler mode needs Pester 5.4 or later; 5.9.0 satisfies that and matches the version CI already runs.
- D2: Profiler mode is set as data: `UseBreakpoints = $false` in the `CodeCoverage` block of both `pester.runsettings.psd1` copies, which `Invoke-PoshQCTest` loads. All local runners inherit it. The bundled-parity pytest requires both copies to change identically.
- D3: If the conditional sharding phase triggers, it adds no new failing CI coverage threshold. The merge job enforces a completeness guard (no test file dropped) and reports repo-wide LINE coverage; threshold enforcement remains review-time.
- D4: The #936 test-header notes are not on this branch. This item records the observed `ci` values of the three #936 lines from the PR-head coverage artifact as evidence and does not edit #936-owned test files.
- D8: Add a Pester major-version ceiling below 6.0 alongside the 5.9.0 minimum, so that a runner image that ships Pester 6 cannot change the major version silently. Sites that filter installed versions (`Install-PoshQCTool` present and post-install checks, the `.devcontainer/post-create.sh` and `.github/codex/codex-web-setup.sh` present-checks) use an exclusive bound of 6.0.0. Sites that call `Import-Module` (the `Invoke-PoshQCTest` default `EnsureModule` seam and the `_poshqc.yml` Linux job) use `-MaximumVersion 5.99.99`, because `Import-Module` has only an inclusive maximum. `scripts/host-tools.manifest.json` carries no ceiling: HostBootstrap installs its exact `minimumVersion`, and `HostVerification.psm1` is unchanged.
- Ownership: item #952 owns `.github/workflows/ci.yml` and every workflow `on:` block; this item edits only `_poshqc.yml` job and step bodies. Policy files are read-only.

## Rollout & Follow-up

- Release/rollout steps: merge via PR; bundled change ships with the next drm-copilot extension and MCP package release (CHANGELOG `[Unreleased]`).
- Post-fix monitoring or clean-up tasks: record the first `main` CI run timing after merge (research §7); report the AC-12 observations to #936.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/953; research `research/research.2026-10-16T04-28.md`; related items #936, #952.
