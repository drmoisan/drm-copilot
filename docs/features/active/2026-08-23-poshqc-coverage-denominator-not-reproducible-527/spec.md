# 2026-08-23-poshqc-coverage-denominator-not-reproducible (Spec)

- **Issue:** #527 (canonical; absorbs item 1 of #623)
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T16-00
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Technical basis:** `research/research.2026-09-29T15-40.md`

## Context

The PowerShell line-coverage denominator reported by the PoshQC test run cannot be reproduced across
sessions. Three denominators (6020, 5969, 6622) were recorded during issue #500. The 5969 and 6622
figures came from the same commit with an identical test result (3362 passed, 9 skipped, 0 failed).
Because the test result was the same, the difference lies in what was measured, not in what was run.

A related defect is reported as item 1 of #623. In a consumer repository, `run_poshqc_test` writes
`artifacts/pester/powershell-coverage.xml` with zero covered lines for every file, even when the
consumer's test suite passes. This spec consolidates that item into #527 because the two symptoms
have the same root cause (see Root Cause Analysis). Items 2 and 3 of #623 are out of scope.

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Severity is Medium. No gate currently fails, and the defect does not affect the correctness of shipped code. The
defect affects the integrity of the measurement. A coverage figure that cannot be reproduced cannot
be compared against a baseline, so the "no regression on changed lines" requirement in
`.claude/rules/general-unit-test.md` cannot be evaluated for PowerShell. Because Pester does not
measure branch coverage, the line figure is the only PowerShell coverage signal. An unstable
denominator can also hide a real regression: a drop in covered lines can be offset by a smaller
denominator and still report a passing percentage. In consumer repositories, the coverage figure
currently carries no information about the consumer's own code.

## Repro & Evidence

Steps to Reproduce (#527):
1. Run `mcp__drm-copilot__run_poshqc_test` over the full suite, then record the line-coverage percentage and its denominator.
2. Run the self-hosted module (`scripts/dev-tools/run-poshqc-suite.ps1 -WorkspaceRoot .`) against the same commit.
3. Compare the denominators and the per-file `<sourcefile>` sets in `artifacts/pester/powershell-coverage.xml`.

Steps to Reproduce (#623 item 1):
1. In a consumer repository that received push-down (so its `.claude/hooks` and `.claude/lib` trees exist), run `run_poshqc_test`.
2. Inspect `artifacts/pester/powershell-coverage.xml`. Every measured file is a pushed-down drm-copilot file with zero covered lines, and none of the consumer's own production files appears.

Expected: For an unchanged tree, the measured file set and the denominator are a deterministic
function of the workspace being tested. They do not depend on the invocation route, on which
settings copy was loaded, or on the current directory. In a consumer repository, the measured set
contains the consumer's own production files.

Actual (#527):

| Denominator | Reported coverage | Route | Recorded in |
| --- | --- | --- | --- |
| 6020 | not recorded | MCP and self-hosted (70 files) | `evidence/qa-gates/final-powershell-poshqc-test.2026-08-22T00-30.md:38` |
| 5969 | 96.47% | MCP | `evidence/qa-gates/final-powershell-poshqc-test.2026-08-23T02-59.md` |
| 6622 | 96.18% | self-hosted (79 files) | `2026-08-23T04-45-audit/code-review.2026-08-23T04-45.md:329` |

The paths above are relative to `docs/features/completed/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/`.

## Scope & Non-Goals

- In scope:
  - Derive the Pester coverage population deterministically from the workspace under test, using a new PoshQC sub-module `PoshQC.Coverage.psm1`.
  - Resolve `-Root` to an absolute path in `Invoke-PoshQCTest`.
  - Remove the hand-maintained per-file `CodeCoverage.Path` allow-list from both runsettings copies and keep the copies byte-identical.
  - Add `config/poshqc-coverage.json` for this repository.
  - Add a committed consumer fixture tree at `tests/fixtures/poshqc-consumer/` that is used for acceptance evidence.
  - Add or update unit tests, the bundled-parity list, and the README coverage description in both copies.
  - Record the related potential entry `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` as superseded by #527. The plan decides whether to move or annotate it.
- Out of scope / non-goals:
  - Items 2 and 3 of #623.
  - Publishing or releasing the extension or the `@danmoisan/drm-copilot-mcp` package. Also out of scope is making the MCP `run_poshqc_test` route show the fix, because that route reads the installed or npx-cached package.
  - Pinning the MCP package version in `.mcp.json`.
  - Adding a PowerShell coverage threshold gate to CI.
  - Raising the repository aggregate PowerShell line coverage to 85% if the larger population lowers it. Any shortfall becomes a follow-up item (see Coverage Policy).
  - Changes to `extensions/drm-copilot/src/poshqc-scan-config.ts` or the `config/poshqc-scan.json` schema.
  - Reducing pre-existing over-limit test files (`PoshQC.Tests.ps1`, `PoshQC.Comprehensive.Tests.ps1`).
- Explicitly excluded systems, integrations, or datasets:
  - Frozen blast-radius fixtures under `tests/fixtures/blast_radius/` must not be edited.
  - Bundle mirrors under `extensions/drm-copilot/resources/` are not coverage roots. Byte-identity parity continues to guard them.

## Root Cause Analysis

The following is verified from code; see research sections 1, 2, and 4. For a fixed Pester version,
the JaCoCo `LINE` denominator depends only on the set of files measured and on the content of those files. PoshQC
sets the measured set to the `CodeCoverage.Path` list in the settings file that was loaded, minus
entries that do not exist on disk (`PoshQC.Testing.psm1:338-367`). The settings file always resolves
relative to the imported module (`PoshQC.psm1:1-3`), and no entry point passes `-SettingsPath`, so:

- The self-hosted route reads the repository copy, `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`.
- The MCP and extension routes read the bundled copy inside the published package. That copy is resolved through an unpinned npx cache (`.mcp.json`).

Two routes over the same tree therefore measure different file sets. The 5969 and 6622 figures
match this mechanism: the old bundled 70-entry list against the new repository 79-entry list, both
over the same post-#501 file contents. This attribution is likely but unconfirmed, because per-file
counters were not recorded. A relative `-Root` is also never resolved to an absolute path, so Pester
resolves relative entries against `$PWD`. This is a second, latent source of variance.

For #623 item 1, a consumer runs with the bundled drm-copilot allow-list. Entries for
`scripts/...` do not exist in the consumer and are pruned. Entries for `.claude/...` and `.codex/...`
survive because push-down copied those files. Coverage stays enabled, Pester measures only the
pushed-down drm-copilot files, and the consumer's tests never execute them, so every file reports
zero covered lines. The consumer's own production files are never in the population. This
mechanism is verified from code and bundle contents, but has not been confirmed against a consumer's
actual XML. The fixture acceptance criterion turns it into a reproducible check that is shown to fail first.

Shared root cause: the coverage population is a hand-maintained, drm-copilot-specific list whose
version depends on the loaded module copy. It is not derived from the workspace under test.

The allow-list also omits production PowerShell files under the configured roots, which the Coverage
Exclusion Policy does not allow. Research section 5.2 and Numeric Derivation Evidence N2 list these
files. Once the population is derived, those files enter the denominator.

## Proposed Fix

### Design summary (what changes where):

- New sub-module `scripts/powershell/PoshQC/PoshQC.Coverage.psm1`, loaded by `PoshQC.psm1`. It owns the coverage-config reader and the population derivation.
- `PoshQC.Testing.psm1`:
  - Resolves `$Root` to an absolute path.
  - Replaces allow-list resolution and pruning with a call to the population resolver through a new injectable seam (for example `-ResolveCoveragePopulation`).
  - Logs the population source and file count.
- Both runsettings copies drop the `CodeCoverage.Path` list. They keep `Enabled`, `OutputFormat`, `OutputPath`, and `CoveragePercentTarget`.
- New `config/poshqc-coverage.json` for this repository.
- The bundled mirror under `extensions/drm-copilot/resources/powershell/PoshQC/` receives the same changes and stays byte-identical. `PoshQC.Coverage.psm1` is added to `POSHQC_PARITY_PATHS`.

### Boundaries and invariants to preserve:

- Byte-identity parity between the repository PoshQC files and their bundled mirrors (`tests/scripts/dev_tools/test_poshqc_bundled_parity.py`).
- Issue #409 semantics: an empty population disables coverage and logs a message. It never passes an empty enabled path set to Pester, and coverage problems never abort the test run.
- Coverage Exclusion Policy: the derivation is include-only. Built-in exclusions are limited to test files (`*.Tests.ps1`), paths whose first root-relative segment is `tests`, and `DefaultExcludedDirs` segments. No configuration key can exclude a production file.
- 500-line limit: `PoshQC.Testing.psm1` (463 lines at HEAD) must not exceed 500 lines. Derivation logic lives in the new sub-module.
- New functions stay internal (not added to `PoshQC.psd1` `FunctionsToExport`). Tests reach them through `InModuleScope`.

### Dependencies or blocked work:

- None blocking. Pester 5.6.1 (pinned by `Install-PoshQCTool`) coverage semantics are assumed (research 1.5).

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

- Production: `scripts/powershell/PoshQC/PoshQC.Coverage.psm1` (new), `PoshQC.Testing.psm1`, `PoshQC.psm1`, `settings/pester.runsettings.psd1`, `README.md`.
- Bundled mirror: the same five paths under `extensions/drm-copilot/resources/powershell/PoshQC/`.
- Configuration: `config/poshqc-coverage.json` (new). If the plan chooses the ignore mechanism for fixture output, also `.gitignore`.
- Tests:
  - New: `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1`.
  - Adapt or review as needed: `PoshQC.TestingCoveragePruning.Tests.ps1`, `PoshQC.TestingInvokeConfigPaths.Tests.ps1`, `PoshQC.ScanFolders.Tests.ps1`, `PoshQC.Tests.ps1`, `PoshQC.Comprehensive.Tests.ps1`, and `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
  - Do not grow the files that are over or near 500 lines.
- Fixture: `tests/fixtures/poshqc-consumer/`, containing `scripts/Sample.psm1`, `tests/scripts/Sample.Tests.ps1` (which imports `Sample.psm1` through `$PSScriptRoot`), and a pushed-down stand-in `.claude/hooks/validate-bash.ps1`. It has no `config/poshqc-coverage.json`, so the fallback path is exercised.

#### Functions/classes/CLI commands impacted:

- `Invoke-PoshQCTest`: absolute root resolution, the new population seam, and population logging. No public parameter is removed.
- New internal functions in `PoshQC.Coverage.psm1`, for example a coverage-config reader modelled on `Get-PoshQCScanConfigFolder` and a population resolver that reuses `Get-PoshQCFileList`.

#### Data flow and validation changes:

Coverage population precedence, evaluated once per run:

1. **Settings.** A non-empty `CodeCoverage.Path` in the loaded settings file, which only applies to a caller-supplied custom settings file, since the shipped copies carry none. It is honored as given and logged with source `settings`.
2. **Workspace config.** The roots listed in `<Root>/config/poshqc-coverage.json`. Logged with source `config`.
3. **Fallback.** The effective test scan folders: explicit `-ScanFolders`, else `config/poshqc-scan.json`, else settings `Run.Path`. Logged with source `fallback`.

Enumeration for sources 2 and 3:
- Skip roots that do not exist, with a warning per root.
- Recurse each existing root and keep `.ps1` and `.psm1` files.
- Exclude `*.Tests.ps1`, any path containing a `DefaultExcludedDirs` segment, and any path whose first repository-relative segment is `tests`.
- Normalize, de-duplicate case-insensitively, and sort ordinally. The resulting list is repository-relative for comparison and logging, and absolute when handed to Pester.
- If the resulting population is empty, disable coverage and log a message. Keep the #409 behavior.

`config/poshqc-coverage.json` validation:
- The schema is `{"version": 1, "roots": ["<relative path>", ...]}`.
- Fail fast, naming the file, on malformed JSON, an unsupported version, a missing or non-array `roots`, or blank, absolute, or `..`-containing entries.
- If every listed root is missing, the run warns per root and then disables coverage. It does not throw.

#### Error handling and logging updates:

- One log line before Pester runs, stating the population source (`settings`, `config`, or `fallback`) and the measured file count.
- A warning per skipped nonexistent root.
- The existing "coverage disabled" log line for an empty population is kept.
- A configuration error names `config/poshqc-coverage.json` and the offending value.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. To roll back, revert the change set. A caller that needs the old behavior can supply a custom settings file with an explicit `CodeCoverage.Path` (precedence 1).

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Input: `config/poshqc-coverage.json` (UTF-8 JSON, schema above).
- Output: the unchanged artifact locations `artifacts/pester/powershell-coverage.xml` and `pester-junit.xml` under `<Root>`.

#### Required configuration keys and defaults:

- `config/poshqc-coverage.json` for this repository has the roots `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, and `scripts`. It does not list `.claude` itself, which would pick up `.claude/worktrees` and `.claude/skills`. It does not list `extensions/`.
- If the file is absent, the fallback derivation applies (no default file is required).

#### Backward-compatibility expectations:

- A custom settings file with an explicit `CodeCoverage.Path` behaves as before, including pruning of nonexistent entries.
- `config/poshqc-scan.json` and its TypeScript writer are unchanged.
- The measured population for this repository grows to include production files that the allow-list omitted. This is intended.

#### Performance constraints (latency/throughput/memory):

- Directory enumeration adds no more than a negligible cost relative to the Pester run. No explicit latency target applies.

## Assumptions, Constraints, Dependencies

- Assumptions:
  - The executor has `pwsh`, Pester 5.6.1, and Poetry available.
  - Acceptance evidence comes from invoking the self-hosted module directly and parsing `artifacts/pester/powershell-coverage.xml`. The MCP `run_poshqc_test` tool reads the installed extension's copy and returns no counts, so it cannot serve as evidence for this change.
- Constraints:
  - Unit tests must not create temporary files. `TestDrive:`, `New-TemporaryFile`, `GetTempPath`, `$env:TEMP`, and `$env:TMP` are prohibited. Filesystem and JSON I/O are supplied through injectable seams: `-EnumerateFiles` returning `[pscustomobject]@{ FullName; Extension; Name }` fakes, `-ReadContent` returning JSON text, and `-TestPathExists`.
  - Evidence artifacts are written under `<FEATURE>/evidence/<kind>/`.
- External dependencies: none new.

## Data / API / Config Impact

- User-facing or API changes:
  - New optional workspace file `config/poshqc-coverage.json`.
  - The shipped runsettings no longer list coverage files.
  - Consumers without the config file get their own production files measured through the fallback.
- Data or migration considerations: none. Consumers need no migration.
- Logging/telemetry updates: population source and file count, plus per-root warnings.
- Compatibility notes: the explicit settings `CodeCoverage.Path` is still honored. The next extension and MCP release carries the change to consumers. That release is out of scope here.

## Coverage Policy

- New and changed production code must reach at least 85% line coverage. This covers `PoshQC.Coverage.psm1` and the changed lines in `PoshQC.Testing.psm1` and `PoshQC.psm1`.
- The repository aggregate PowerShell line coverage over the derived population is reported as evidence. It is **not** a gate for this issue, because CI enforces no PowerShell threshold. If the aggregate is below 85%, the shortfall and the contributing files are recorded in the evidence as a follow-up item for the execution-phase orchestrator to file.
- Excluding production files, or narrowing `config/poshqc-coverage.json` roots, to raise the aggregate is prohibited.

## Test Strategy

- Regression tests to add or update (Pester, `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1`). Each test must be shown to fail against pre-fix behavior where applicable:
  - Route independence (#527): identical injected tree and workspace config with two different settings tables (repository copy versus bundled copy) produce equal captured `CodeCoverage.Path` sets.
  - Workspace-derived population (#623): with an injected tree containing `scripts/Sample.psm1`, `tests/scripts/Sample.Tests.ps1`, and `.claude/hooks/validate-bash.ps1`, and with the shipped settings, the population is exactly `scripts/Sample.psm1`.
  - Determinism: shuffled enumeration order, case-variant duplicates, and overlapping roots yield the same sorted, de-duplicated list.
- Unit tests for the fixed behavior and boundaries:
  - Precedence (settings, then config, then fallback).
  - Config validation failures.
  - Missing-root warnings.
  - All-roots-missing disable.
  - Empty-population disable (#409).
  - Relative `-Root` resolution.
  - Logging of the source and the count.
- Existing coverage-pruning tests are kept or adapted so #409 semantics stay covered.
- Toolchain commands (self-hosted):
  - `Invoke-PoshQCFormat`, then `Invoke-PoshQCAnalyze`, then `Invoke-PoshQCTest` on `scripts/powershell/PoshQC/PoshQC.psd1`.
  - Then `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py`.
- Manual/executor validation:
  - Run the repository twice with an absolute `-Root`, plus once from a different current directory.
  - Run the consumer fixture before and after the fix.
  - Parse the coverage XML for each run.

## Acceptance Criteria

- [ ] Deterministic derivation: two self-hosted `Invoke-PoshQCTest` runs over this unchanged repository produce an identical set of `<sourcefile>` entries and an identical root `LINE` counter total (missed + covered) in `artifacts/pester/powershell-coverage.xml`. A third run launched from a different current directory with the same absolute `-Root` matches as well. The comparison is recorded under `evidence/`.
- [ ] Route independence: a Pester test in `tests/scripts/powershell/PoshQC/PoshQC.Coverage.Tests.ps1` runs `Invoke-PoshQCTest` with an identical injected tree and workspace config but two different settings tables, and asserts that the captured coverage population is identical. Evidence shows the test failing against pre-fix code.
- [ ] Derived population contents: for sources `config` and `fallback`, the population equals the set of `.ps1` and `.psm1` files under the effective roots. That set excludes `*.Tests.ps1`, paths whose first repository-relative segment is `tests`, and `DefaultExcludedDirs` segments. It is de-duplicated case-insensitively and sorted ordinally. Unit tests with shuffled enumeration order, case-variant duplicates, and overlapping roots verify this.
- [ ] Precedence order: unit tests verify that a non-empty `CodeCoverage.Path` in a caller-supplied settings file takes precedence over `config/poshqc-coverage.json`, and that the config file takes precedence over the fallback to the effective test scan folders (explicit `-ScanFolders`, else `config/poshqc-scan.json`, else settings `Run.Path`).
- [ ] Observability: before Pester runs, `Invoke-PoshQCTest` logs the population source (`settings`, `config`, or `fallback`) and the measured file count. Unit tests assert this output.
- [ ] Config validation: a malformed `config/poshqc-coverage.json` fails fast with an error naming the file. Malformed means invalid JSON, an unsupported version, a missing or non-array `roots`, or a blank, absolute, or `..` entry. A nonexistent root is skipped with a warning. When every root is missing, or the population is empty, coverage is disabled with a log line and the run is not aborted. Unit tests verify each case.
- [ ] Absolute root: a relative `-Root` (for example `.`) is resolved to an absolute path before any run, coverage, or output path is built. A unit test verifies that the paths passed to Pester are absolute.
- [ ] Allow-list removed: neither `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` nor `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` contains a `CodeCoverage.Path` entry list. Both keep `Enabled`, `OutputFormat`, `OutputPath`, and `CoveragePercentTarget`.
- [ ] Parity preserved: `PoshQC.Coverage.psm1` is added to `POSHQC_PARITY_PATHS`, and every changed or new PoshQC file is byte-identical to its mirror under `extensions/drm-copilot/resources/powershell/PoshQC/`. `poetry run pytest tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes.
- [ ] `config/poshqc-coverage.json` exists with `"version": 1` and exactly these roots: `.claude/hooks`, `.claude/lib`, `.codex/hooks`, `.codex/scripts`, `scripts`. A self-hosted repository run logs source `config`.
- [ ] Consumer fixture coverage: `tests/fixtures/poshqc-consumer/` is committed. It contains a small production script, a Pester test that exercises it, and a pushed-down stand-in `.claude/hooks/validate-bash.ps1`, and it has no `config/poshqc-coverage.json`. The self-hosted `Invoke-PoshQCTest -Root <fixture>` run records a covered `LINE` count greater than zero for the fixture's production file, and `pester-junit.xml` reports zero failures. Evidence records the pre-fix run failing this check.
- [ ] Consumer isolation: in the fixture run's `powershell-coverage.xml`, no `<sourcefile>` refers to a drm-copilot file. This includes the stand-in `validate-bash.ps1` and any path outside the fixture tree.
- [ ] Fixture output hygiene: after the fixture run, `git status --porcelain` shows no untracked or modified files produced by the run, either because the output is gitignored or because it is removed. The plan chooses the mechanism.
- [ ] New code coverage: `PoshQC.Coverage.psm1` and the changed lines in `PoshQC.Testing.psm1` and `PoshQC.psm1` reach at least 85% line coverage in the self-hosted run. The repository aggregate is recorded in evidence, and any aggregate below 85% is recorded as a follow-up item. No production file is excluded to raise it.
- [ ] Existing suite: the full self-hosted Pester suite passes with zero failures, and PoshQC format and analyze report no findings on changed files.
- [ ] Documentation: `scripts/powershell/PoshQC/README.md` and its bundled mirror replace the stale coverage-glob description. The new text documents `config/poshqc-coverage.json`, the precedence order, the built-in exclusions, and the fallback behavior.
- [ ] No temporary files in tests: no new or changed test uses `TestDrive:`, `New-TemporaryFile`, `GetTempFileName`, `GetTempPath`, `$env:TEMP`, or `$env:TMP`. Filesystem and JSON access in unit tests goes through injected seams, and `.claude/hooks/check-powershell-test-purity.ps1` reports no violation.
- [ ] `PoshQC.Testing.psm1` and every new production or test file remain at or under 500 lines. Pre-existing over-limit test files are not grown.

## Risks & Mitigations

- Technical or operational risks:
  - The larger population may lower the repository aggregate below 85%.
  - Existing tests that inject `CodeCoverage.Path` may need adaptation.
  - The MCP and extension routes keep showing the old behavior until a release ships.
  - A directory-based derivation could pick up untracked scratch `.ps1` files.
- Mitigations and rollbacks:
  - The aggregate is evidence-only, and any shortfall becomes a follow-up item.
  - Tests are adapted through the new population seam.
  - The release dependency is documented as out of scope.
  - The logged source and file count make any population change visible in the run output.
  - To roll back, revert the change set.

## Rollout & Follow-up

- Release/rollout steps: none in this issue. The change reaches consumers with the next extension and MCP release.
- Post-fix monitoring or clean-up tasks:
  - File a follow-up issue if the aggregate PowerShell line coverage falls below 85%.
  - Record `docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md` as superseded by #527.
- Links: issue #527, issue #623 (item 1), research `research/research.2026-09-29T15-40.md`, and the related potential entry above.
