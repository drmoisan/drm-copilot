# 2026-11-15-test-launcher-drops-positional-jest-path (Spec)

- **Issue:** #1192
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-15T12-30
- **Status:** Draft
- **Version:** 0.2

## Context
The test-execution-policy launcher (`run-test-suite.sh`, added by #1158) drops a positional Jest test-file argument, so a targeted Jest task check silently runs the whole Jest suite instead of the named file. The #1173 run reported it (PR #1185). It wastes time under the one-suite-at-a-time machine lock and makes a targeted check's evidence misleading.

Environment:
- OS/version: Windows 11 (local), Claude Code runtime
- Python version: not applicable
- Command/flags used: the launcher with the Jest lane and a positional test path, for example a single `extensions/drm-copilot/tests/...test.ts` file
- Data source or fixture: reported in PR #1185 (issue #1173) "Not fixed" notes

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Repro & Evidence
Steps to Reproduce:
1. Run a Jest task check through the launcher, passing one test file as a positional argument.
2. Observe that the whole Jest suite runs instead of the named file.

Expected:
Positional test paths are forwarded to Jest in a position where Jest parses them as test-path patterns, so a targeted check runs only the named files; the launcher still applies its lock and lane rules.

Actual:
The positional path is not parsed as a test-path pattern; the full suite runs with no warning.

Evidence: PR #1185 body. The mechanism below is inferred from the Jest option definition and the builder's word order; it was not reproduced with a live full Jest run. Fail-before evidence is a builder-order unit test that fails against the unmodified builder.

## Scope & Non-Goals
- In scope:
  - Word order in `New-TestExecutionSuiteCommand` for the Jest and Pester runners.
  - The four byte-identical copies of `test-execution-policy.ps1`.
  - Updating and adding Pester tests for the builder and the launcher.
  - Correcting the stale comment in `extensions/drm-copilot/jest.config.cjs`.
- Out of scope / non-goals:
  - Changing `run-test-suite.sh`, `Invoke-TestSuite.ps1`, or `run-jest.cjs`; research shows they forward every word unchanged.
  - Changing lane-refusal, worker-reduction, or machine-lock behavior.
  - Changing pytest, dotnet-test, or bats command order.
  - Updating the `execution-environment` brief or the `test-execution-policy` SKILL.md copies; no fact they state changes. Update them only if the plan chooses to document the selector rule, in which case the brief contract test must be rerun.
  - Adding any Python.
- Explicitly excluded systems, integrations, or datasets: none.

## Root Cause Analysis
`New-TestExecutionSuiteCommand` in `.claude/hooks/test-execution-policy.ps1` emits the suite command words, then the lane-exclusion words from `Get-TestExecutionLaneExclusionArgument`, then the caller's extra arguments. The launcher (`Invoke-TestSuiteLauncher`) and the shell shim forward every word correctly; the defect is the order.

Jest: the exclusion words are repeated `--testPathIgnorePatterns=...` options. Jest declares `testPathIgnorePatterns` as an array option, and its argument parser lets an array option consume following non-flag tokens. A positional placed after the last exclusion word is therefore parsed as one more ignore pattern, not as a test-path pattern. Jest runs the whole suite and additionally skips the named file.

Pester: the exclusion emits `-ExcludeTestFileSuffix <suffix...>`, an array key. In `ConvertTo-PesterSuiteParameter`, a bare word after that key becomes another suffix value silently. A `-TestPath <paths>` extra starts a new key and is not absorbed, but only reordering guarantees a path selector cannot be consumed by the suffix array.

pytest uses single-value `-m` and `--ignore-glob=` words, dotnet-test uses one `--filter=` word, and bats has no exclusions; positionals after these are collected normally, so they have no defect.

The stale comment in `extensions/drm-copilot/jest.config.cjs` above the `jest.docs-coverage.json` require describes a smaller number of docs MCP modules than `jest.docs-coverage.json` now lists. It is corrected in the same change.

## Proposed Fix

### Design summary (what changes where):
In `New-TestExecutionSuiteCommand`, for runners whose exclusions are array options (jest and pester), emit the caller's extra arguments before the exclusion words. The Pester selector form remains `-TestPath <paths>`. For pytest, dotnet-test, and bats the order stays suite words, exclusions, extras. No function signature changes.

Rejected alternatives: terminating the array with a `--` sentinel (depends on unverified Jest `--` handling and changes the command shape for every caller); folding exclusions into one `--testPathIgnorePatterns` word (still an array option, does not fix the defect).

### Boundaries and invariants to preserve:
- Lane refusal for excluded integration and golden suffixes happens on the extras before the build and exits 2 with `TEST_EXECUTION_POLICY_BLOCKED:`.
- Worker-reduction tokens (`--runInBand`, `-i`, `-w`, `--maxWorkers`) exit 2.
- The machine lock is acquired after the build and before the process starts.
- No exclusion word is lost by the reorder.
- With no extras, the command is unchanged.

### Dependencies or blocked work:
None.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `.claude/hooks/test-execution-policy.ps1` and its three byte-identical copies: `.codex/hooks/`, and the two `extensions/drm-copilot/resources/` bundle copies (claude-customizations and codex-and-agents-customizations).
- `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` (existing Jest case updated; new cases added).
- `tests/scripts/claude-skills/test-execution-policy/Invoke-TestSuite.Tests.ps1` (launcher-level Jest case with a positional).
- `extensions/drm-copilot/jest.config.cjs` (comment only).

#### Functions/classes/CLI commands impacted:
`New-TestExecutionSuiteCommand`; consumers through `Invoke-TestSuiteLauncher` and `run-test-suite.sh` observe the new order only.

#### Data flow and validation changes:
Order of words in the built command only; no new validation.

#### Error handling and logging updates:
None.

#### Rollback/feature-flag considerations (if applicable):
Revert the builder change in all four copies together.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Input: suite name plus extras. Output: an ordered command word list. For jest: `<suite command words> <extras> <--testPathIgnorePatterns words>`. For pester: `<suite command words> <extras> <exclusion words>`.

#### Required configuration keys and defaults:
None added. `config/test-execution-policy.json` is unchanged.

#### Backward-compatibility expectations:
Callers passing no extras, and all pytest, dotnet-test, and bats callers, see identical commands.

#### Performance constraints (latency/throughput/memory):
None; a targeted check now runs fewer tests.

## Assumptions, Constraints, Dependencies
- Assumptions: the Jest array-option parsing behavior is as inferred from its option definition; the unit test pins the word order that avoids it.
- Constraints: PowerShell and bash only, no new Python. Tests run in parallel only, in-memory, no temp files, no drive letters or backslash literals (the Linux hook-suite job runs these tests). Keep `test-execution-policy.ps1` under the 500-line guidance or extract the exclusion builder.
- External dependencies: none.

## Data / API / Config Impact
- User-facing or API changes: targeted Jest and Pester selectors now take effect.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): no flag or schema change.

## Test Strategy
- Regression tests to add or update (Pester, in-memory via `Get-TestPolicy -Text`):
  - Update `builds the jest suite with one --testPathIgnorePatterns word per pattern and keeps a positional extra` so it asserts the positional precedes the first ignore word, all ignore words remain, and the reason for the change is stated in the test.
  - Add: single positional on jest precedes the first `--testPathIgnorePatterns` word; positional plus a flag extra; no extras leaves the command unchanged.
  - Add: Pester `-TestPath a b` extra precedes the exclusion words and the exclusion words are intact.
  - Add: pytest, dotnet-test, and bats command order unchanged with extras.
  - Add: a launcher-level `jest-extension` case with a positional asserting `ArgumentList` order, and that an integration-suffix operand still returns 2.
- Edge cases and negative scenarios: excluded integration and golden operands still refused; worker-reduction tokens still refused.
- Coverage impact and targets for changed lines/modules: changed lines in `test-execution-policy.ps1` at or above the repository line-coverage threshold, covering both the jest and pester reorder paths.
- Toolchain commands to run: format, lint, then the Pester suites for claude-hooks, codex-hooks, and claude-skills test-execution-policy, then the push-down resource contract tests and pack manifest tests, in a single parallel gate run.
- Manual validation: none required; no heavy live Jest run.

## Acceptance Criteria
- [x] AC-1 (Jest single file): For a `jest-extension` or `jest` suite with a single positional test file as the only extra, `New-TestExecutionSuiteCommand` returns a command that names only that file as a test selector and places it before the first `--testPathIgnorePatterns` word; a test asserts this order and that every exclusion word is still present. Evidence: P1-T1, P3-T2.
- [x] AC-2 (Pester): For the `pester` suite with a `-TestPath <path>` extra, the built command places the extra before `-ExcludeTag` and `-ExcludeTestFileSuffix`, with the exclusion words intact; a test asserts this order. Evidence: P1-T2, P3-T2.
- [x] AC-3 (no positional): With no extras, the Jest and Pester commands equal the pre-change full-suite commands; a test asserts the unchanged word list. Evidence: P1-T2, P3-T2.
- [x] AC-4 (lane and worker rules): An integration or golden operand is still refused with `TEST_EXECUTION_POLICY_BLOCKED:`, and `--runInBand`, `-i`, `-w`, and `--maxWorkers` are still refused with the same nonzero exit as before; the machine lock is acquired after the build and before the process starts, unchanged; a launcher-level test asserts the refusal alongside a valid positional case. Evidence: P1-T3.
- [x] AC-5 (other legs unchanged): A test asserts that pytest, dotnet-test, and bats built commands with extras keep the order suite words, exclusions, extras. Evidence: P1-T2, P3-T2.
- [x] AC-6 (all copies): `test-execution-policy.ps1` is byte-identical across `.claude/hooks`, `.codex/hooks`, and every `extensions/drm-copilot/resources` bundle copy, and the push-down resource contract tests and pack manifest tests pass. Evidence: P2-T2, P3-T3.
- [x] AC-7 (existing test updated): The existing Jest case in `tests/scripts/claude-hooks/test-execution-policy.Tests.ps1` is updated, not weakened or removed, with a comment stating that the positional now precedes the exclusion words and why. Evidence: P1-T1.
- [x] AC-8 (stale comment): The comment above the `jest.docs-coverage.json` require in `extensions/drm-copilot/jest.config.cjs` no longer understates the module count and matches the entries of `jest.docs-coverage.json`. Evidence: P2-T5.
- [x] AC-9 (no collateral change): `run-test-suite.sh`, `Invoke-TestSuite.ps1`, `run-jest.cjs`, `config/test-execution-policy.json`, and the `execution-environment` brief are unchanged unless a documented fact there changes, and no Python file is added. Evidence: P3-T4.
- [x] AC-10 (toolchain): Format, lint, and the affected Pester suites pass in a single parallel run with no serial, single-process, or shuffled runs, and changed-line coverage meets the repository threshold. Evidence: P3-T1, P3-T2.

## Risks & Mitigations
- Technical or operational risks: a copy of the hook drifts from the others; the Jest cause is inferred, not reproduced live.
- Mitigations and rollbacks: parity contract tests gate the four copies; builder-order tests fail against the unmodified builder and give fail-before evidence; revert all four copies together.

## Rollout & Follow-up
- Release/rollout steps: ships with the next extension build; a push-down serves the installed payload, so a rebuild and reinstall is needed before downstream repositories see it.
- Post-fix monitoring or clean-up tasks: none.
- Links: issue #1192, PR #1185, issue #1173, issue #1158
