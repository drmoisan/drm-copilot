# run-actionlint-test-path-env-leak (Spec)

- **Issue:** #1066
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-03
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Research:** `research/research.md`

## Context
The Pester test "Add-DirectoryToPath handles paths with trailing separator" (Context `Edge cases`) in tests/scripts/dev-tools/run-actionlint.Tests.ps1 sets `$env:PATH` and never restores it. In a single-process Pester run, later suites inherit the altered PATH and fail. This is a test-order dependence, which repository policy treats as a violation. The same file also sets `$global:LASTEXITCODE` from mocks and tests without restoring it.

Environment:
- OS/version: Linux Codespace (PowerShell 7.6, Pester 5.9.x); CI runs the suite on windows-latest, where each shard is a separate process and the leak is not visible.
- Command/flags used: Invoke-Pester over tests/scripts/dev-tools in a single process.
- Data source or fixture: none; the test assigns `$env:PATH = '/existing'` directly.

Impact / Severity: Medium.

## Repro & Evidence
Steps to Reproduce:
1. Run Invoke-Pester single-process over tests/scripts/dev-tools including run-actionlint.Tests.ps1.
2. Observe that eight later suites fail.
3. Run the same suites without run-actionlint.Tests.ps1, or with the leaking test excluded; the failures disappear.

Expected: Every test restores process-global state (environment variables) it changes, so suites pass in any order and in a single process.

Actual: After the test runs, `$env:PATH` remains `/new/:/existing`, and later suites fail because commands cannot be resolved.

## Scope & Non-Goals
- In scope: restoring all process-global state mutated by run-actionlint.Tests.ps1 (PATH, `$global:LASTEXITCODE`) at a scope covering every Context; one minimal regression guard.
- Out of scope / non-goals: the roughly 89 pre-existing Linux host failures in 17 dev-tools/PoshQC suites (sibling issue #1067); epic #1019 branches; #1047; any production file; auditing the other 30 test files that assign `$env:` variables.
- Constraints: edit only test files and the minimal guard; no new Python (PowerShell/bash only); tests create no temporary files; evidence is written only under `<FEATURE>/evidence/regression-testing/`.

## Root Cause Analysis
The Add-DirectoryToPath Describe saves and restores PATH in BeforeEach and AfterEach. The `Edge cases` Context has no such restore, so its trailing-separator test leaves PATH altered for every later suite in the process. Research also found `$global:LASTEXITCODE` assignments (values 0 and 3) in the `Invoke-ActionlintExe` and `Invoke-ActionlintCommand` Contexts that are never restored. All seven `$env:PATH =` assignments under tests/scripts are in this file.

## Proposed Fix

### Design summary (what changes where):
- tests/scripts/dev-tools/run-actionlint.Tests.ps1: save `$env:PATH` and `$global:LASTEXITCODE` and restore both at Describe level so every Context is covered.
- New guard test file (for example tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1).

### Boundaries and invariants to preserve:
- No production file changes. Existing Add-DirectoryToPath tests keep their behavior.
- The guard must not itself leak, and must use no temporary files.

### Guard options (plan chooses and records the choice):
- (b) Preferred: run run-actionlint.Tests.ps1 through a nested in-process `Invoke-Pester -PassThru` (no result file, no coverage, verbosity None) and assert the process environment is identical before and after, using a case-insensitive key comparison for Windows.
- (c) Fallback if the nested run proves unstable in single-process or parallel runs: a static AST guard limited to PATH that evaluates restore scope per Context.

### Dependencies or blocked work:
- None. #1067 is independent and must not be mixed in.

## Assumptions, Constraints, Dependencies
- Assumptions: PowerShell 7 and Pester 5.9.x; CI shards run in separate processes.
- Constraints: Windows environment names are case-insensitive and PATH uses `;`; the guard must not assume path format or drive letters.
- External dependencies: none.

## Data / API / Config Impact
- None. Test-only change; no CLI, schema, or telemetry impact.

## Test Strategy
- Regression tests: the new guard file; the existing Add-DirectoryToPath tests continue to pass.
- Edge cases: Windows case-insensitive environment keys; guard run in the same process as other suites.
- Verification: single-process runs via an explicit `Run.Path` list in forward, reversed, and at least three seeded shuffled orders, with JUnit name-set difference separating PATH victims from #1067 host failures (see research Section 4).
- Toolchain: format, PSScriptAnalyzer, Pester for changed files, per `.claude/rules/powershell.md`.

## Acceptance Criteria
- [x] The leaking test "Add-DirectoryToPath handles paths with trailing separator" no longer leaves `$env:PATH` changed: `$env:PATH` after run-actionlint.Tests.ps1 equals its value before, verified by a single-process run.
- [x] A save/restore of `$env:PATH` covers every Context in run-actionlint.Tests.ps1 (Describe level preferred), so no Context depends on a sibling Context's restore.
- [x] Every other unrestored process-global mutation in run-actionlint.Tests.ps1 identified by research, including `$global:LASTEXITCODE` set by the `Invoke-ActionlintExe` and `Invoke-ActionlintCommand` mocks and tests, is saved and restored, and no other environment variable, location, alias, or global state remains altered after the file runs.
- [x] A regression guard exists that fails if the guarded suite changes `$env:PATH` or any other process environment variable without restoring it (full-environment comparison, case-insensitive keys), uses no temporary files, and edits no production file.
- [x] The regression guard passes on the fixed tree, including when run in the same process with other tests/scripts/dev-tools suites, and leaves the process environment unchanged itself.
- [x] The regression guard is shown to fail against the pre-fix leak, with fail-before evidence (`Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`) under `evidence/regression-testing/`, or a `fail-before-exception.<timestamp>.md` dossier documents why it could not be shown.
- [x] The plan records which guard form was chosen (nested Invoke-Pester or static AST fallback) and, if the fallback was used, the observed instability that justified it.
- [x] Single-process runs of tests/scripts/dev-tools in forward, reversed, and at least three seeded shuffled file orders (seeds and file orders recorded) show the PATH-induced victim failures removed and no new failures compared with the baseline failure set, compared by test-name set difference from JUnit so the #1067 host failures cancel.
- [x] The full seven-stage toolchain passes in a single pass for the changed PowerShell files (format, PSScriptAnalyzer lint, type check not applicable, architecture-boundary tests, Pester unit tests, contract/schema checks, integration tests), with line coverage not reduced and no coverage `exclude` entry added for a production path.
- [x] Changed and new test files stay under 700 lines each.
- [ ] CI required checks are green on the PR head. (CI-dependent: checked off by the item's orchestrator run at S9 after the CI green gate records success.)

## Risks & Mitigations
- Nested Invoke-Pester shares process-wide Mock/Pester state: verify in single-process and Invoke-PoshQCParallelTest runs; fall back to the static AST guard.
- A local pass in one file order is not proof because CI shard splits vary: verify across multiple orders and seeds.
- Mitigations and rollbacks: test-only change; revert the commit.

## Rollout & Follow-up
- Release/rollout steps: none beyond merge.
- Follow-up: #1067 (Linux host failures) handled separately.
- Links: issue #1066, research/research.md.
