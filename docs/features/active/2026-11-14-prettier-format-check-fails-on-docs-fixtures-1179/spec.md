# 2026-11-14-prettier-format-check-fails-on-docs-fixtures (Spec)

- **Issue:** #1179
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-14T03-36
- **Status:** Draft
- **Version:** 0.2

## Context
The repository-root Prettier format check (`format:check`) fails on JSON fixtures under `tests/scripts/claude-lib/docs/fixtures/`. CI does not run the root check, so the failure is visible only locally, where it makes the format stage of the mandatory toolchain loop fail for every orchestration that runs it.

Environment:
- OS/version: Windows 11 (local); reported by two independent orchestration runs (#1163, #1157) on 2026-11-13
- Python version: not applicable
- Command/flags used: root `npm run format:check` (Prettier `--check`)
- Data source or fixture: `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [ ] Medium
- [x] Low


## Repro & Evidence
Steps to Reproduce:
1. Check out `main`.
2. Run the root Prettier check over the repository (`npm run format:check`).
3. Observe the fixture files reported as not formatted.

Expected:
The root format check passes on `main`, and CI enforces the same check so that a regression fails a PR.

Actual:
Prettier reports formatting differences in the fixtures. CI stays green because no CI job runs the root check.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: Prettier `[warn]` lines naming the fixture files, as reported by the #1163 and #1157 runs.


## Scope & Non-Goals
- In scope:
  - Reformat the fixtures named in the issue with Prettier, with no content change.
  - Add a root format-check step to the existing root TypeScript CI workflow.
  - Format any further file that the full root check flags, in the same change.
- Out of scope / non-goals:
  - No Prettier configuration change.
  - No new CI job.
  - No new Python.
  - No `.prettierignore` change.
- Explicitly excluded systems, integrations, or datasets: `tests/fixtures/` (already ignored for exact bytes, issue #848).

## Root Cause Analysis
The fixtures were committed in a layout Prettier does not produce, and no CI job runs `format:check`, so nothing flagged them. Research (see `research/research.2026-11-14T00-00.md`) read every consumer of the fixtures: Pester suites under `tests/scripts/claude-lib/docs/` and `test_docs_python_native_corpus.py` decode the JSON semantically. No consumer pins whole-file bytes, hashes, lengths or offsets; embedded digests are over decoded source strings, which Prettier does not change. The `.prettierignore` convention is to ignore only where exact bytes matter, which does not apply here.


## Proposed Fix

### Design summary (what changes where):
Format the fixtures named in the issue with Prettier and add one step to the existing CI workflow so the root check runs on every non-docs PR.

### Boundaries and invariants to preserve:
- Decoded JSON value of each fixture is unchanged (key order, strings, numbers).
- `.prettierignore`, Prettier configuration, `ci.yml`, the `ci-required-gate` needs list, and the execution-environment brief copies are unchanged.

### Dependencies or blocked work:
None.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json`, `python-native-corpus.json`, `python-surface-corpus.json`: Prettier formatting only.
- `.github/workflows/_root-typescript-tests.yml`: add step "Check root formatting" running `npm run format:check`, placed after "Install root dependencies".
- Any additional file the full root check flags (none known).

#### Functions/classes/CLI commands impacted:
`npm run format:check` (now run in CI). No source code changes.

#### Data flow and validation changes:
None.

#### Error handling and logging updates:
None.

#### Rollback/feature-flag considerations (if applicable):
Revert the commit; no flags.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Fixtures remain valid JSON, LF line endings.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
All consumers continue to parse the fixtures to identical values.

#### Performance constraints (latency/throughput/memory):
The added CI step is a single Prettier check; no constraint.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): `.gitattributes` enforces LF; Prettier 3 defaults apply (no config).
- Constraints (budget, performance, compatibility): no new CI job, so required-gate contexts stay unchanged; the step does not run on docs-only runs.
- External dependencies (services, libraries, releases): Prettier already in root devDependencies.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): none.

## Test Strategy
- Regression tests to add or update: none required; the CI step is the regression guard. No workflow-text pin is added.
- Unit tests (pytest) for the fixed behavior and boundaries: not applicable (fixtures and workflow YAML only); `test_docs_python_native_corpus.py` is re-run as a regression check.
- Edge cases and negative scenarios: a decoded-value comparison of each fixture before and after formatting (scratch comparison, not committed).
- Error handling and logging verification: not applicable.
- Coverage impact and targets for changed lines/modules: not applicable; no production code changes.
- Toolchain commands to run (format, lint, type-check, test): root `npm run format:check`; docs Pester suites via the parallel runner (one run); `test_docs_python_native_corpus.py` via `pytest -n auto` (one run). Parallel-only; no serial runs.
- Manual validation steps (if required): none.


## Acceptance Criteria
- [x] Root `npm run format:check` succeeds after the change; before the change it fails and lists the fixtures named in the issue.
- [x] The decoded JSON value of each fixture named in the issue is identical before and after formatting.
- [x] Any additional file flagged by the full root `format:check` is formatted in the same change, with no content change.
- [x] The docs Pester suites under `tests/scripts/claude-lib/docs/` pass in a parallel run.
- [x] `tests/scripts/claude-lib/docs/python/test_docs_python_native_corpus.py` passes in a parallel run.
- [x] `.github/workflows/_root-typescript-tests.yml` contains a step named "Check root formatting" running `npm run format:check`, after "Install root dependencies", and it applies to every OS leg of the job matrix.
- [ ] `.prettierignore`, Prettier configuration, `ci.yml` and the `ci-required-gate` needs list are unchanged, and no new CI job or Python file is added.
- [ ] CI-dependent: a green CI run on the final branch head exercises the new step on each OS leg (rule `modified-workflow-needs-green-run`). Stays unchecked until S9.
- [ ] CI-dependent: the existing contract tests that pin workflow and brief contents (`CiRequiredGateWorkflow.Tests.ps1`, `test_execution_environment_brief_contracts.py`) pass in that CI run. Stays unchecked until S9.

## Risks & Mitigations
- Technical or operational risks: a root file other than the fixtures named in the issue (TS tests, `src/hello-typescript.ts`, root configs) may be unformatted and fail only in CI; static analysis could not confirm this.
- Mitigations and rollbacks: run the full `format:check` locally before pushing and format any additional file in the same change; revert the commit to roll back.

## Rollout & Follow-up
- Release/rollout steps: merge via normal PR after green CI.
- Post-fix monitoring or clean-up tasks: none.
- Links: issue #1179; research record `research/research.2026-11-14T00-00.md`.
