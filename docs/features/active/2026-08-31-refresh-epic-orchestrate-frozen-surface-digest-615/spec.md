# 2026-08-31-refresh-epic-orchestrate-frozen-surface-digest (Spec)

- **Issue:** #615
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-31T08-30
- **Status:** Draft
- **Version:** 0.1

## Context
Issue #615 tracks a CI failure caused by a stale frozen-surface digest after the intentionally merged wording change in `.claude/skills/epic-orchestrate/SKILL.md`. The fix is limited to re-baselining the corresponding expectation in the Python test-support module; no runtime document or mirror content changes are required.

Environment:
- OS/version: GitHub Actions runner
- Python version: 3.11
- Command/flags used: quality-checks workflow, `quality-checks7 / Code Quality & Tests (3.11)`
- Data source or fixture: merge head `1432ff895c57113702db70deb2dbb092cefe0296`

Impact / Severity:
- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low


## Repro & Evidence
Steps to Reproduce:
1. Check out merge head `1432ff895c57113702db70deb2dbb092cefe0296`.
2. Run the frozen-surface contract tests in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`.
3. Inspect the digest assertion for `.claude/skills/epic-orchestrate/SKILL.md`.

Expected:
The expected digest equals the SHA-256 digest computed from the current runtime document bytes, so the frozen-surface contract passes.

Actual:
The pinned value is `d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b`, while the exact merge-head bytes produce `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`. CI run `33379396439` failed only this digest assertion in the Python 3.11 quality job; it reported 4,244 passed and 5 skipped tests.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: `quality-checks7 / Code Quality & Tests (3.11)` in run `33379396439`.


## Scope & Non-Goals
- In scope: replace the stale digest string for `.claude/skills/epic-orchestrate/SKILL.md` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` with `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`; preserve all other expectations; rerun the required Python gates and CI.
- Out of scope / non-goals: changing frozen runtime content, removing or weakening the digest assertion, changing the second frozen-file pin, or altering unrelated contract expectations.
- Explicitly excluded systems, integrations, or datasets: `.claude/skills/epic-orchestrate/SKILL.md`, its mirror, production code, runtime configuration, external services, and test fixtures unrelated to the stale tuple.

## Root Cause Analysis
The merge introduced four wording changes to `.claude/skills/epic-orchestrate/SKILL.md` but retained the previous pinned digest. The contract test hashes repository bytes with SHA-256 and compares the result to `PINNED_FROZEN_SURFACE_HASHES`, so the stale tuple fails deterministically. Research found no evidence that the second pin or mirror parity is incorrect.


## Proposed Fix

### Design summary (what changes where):
Update one tuple value in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`. The tuple path remains `.claude/skills/epic-orchestrate/SKILL.md`; only its expected digest changes to the independently computed merge-head value.

### Boundaries and invariants to preserve:
Keep the frozen-surface assertion active; preserve the second frozen-file digest, section/fragment expectations, runtime skill bytes, mirror bytes, and all repository paths. Scope remains zero production files and one Python test-support file.

### Dependencies or blocked work:
The implementation requires the exact runtime-file bytes and the repository Python test environment. Release remains blocked until the focused contract, required Python gates, and CI pass for the resulting commit SHA.

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` only.

#### Functions/classes/CLI commands impacted:
No production functions, classes, or CLI commands. The affected data is `PINNED_FROZEN_SURFACE_HASHES`, consumed by the frozen-surface contract test.

#### Data flow and validation changes:
The contract continues to read the target file as bytes, compute SHA-256, and compare it to the expected tuple. The updated digest makes the expectation agree with the intentional runtime-document revision without changing validation logic.

#### Error handling and logging updates:
No error-handling or logging changes. A mismatch must continue to fail with the existing assertion output.

#### Rollback/feature-flag considerations (if applicable):
No feature flag or migration is required. Rollback is limited to reverting the one expectation value if the runtime document is legitimately reverted.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
Input: raw bytes from `.claude/skills/epic-orchestrate/SKILL.md`. Output: the expected lowercase hexadecimal SHA-256 string in the existing `(relative_path, digest)` tuple format.

#### Required configuration keys and defaults:
None.

#### Backward-compatibility expectations:
The test-support module retains its existing import and tuple schema. Runtime behavior, public interfaces, and frozen-document content remain unchanged.

#### Performance constraints (latency/throughput/memory):
No material change; the existing single-file digest check remains bounded by the frozen document size.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): The merge-head runtime bytes are the intended reviewed content, and the reported digest `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7` is correct.
- Constraints (budget, performance, compatibility): Zero production files and one Python test-support file; no dependency additions; preserve all unrelated expectations.
- External dependencies (services, libraries, releases): GitHub Actions CI and the existing Python toolchain only.

## Data / API / Config Impact
- User-facing or API changes: None.
- Data or migration considerations: None; this is a test expectation re-baseline.
- Logging/telemetry updates (if any): None.
- Compatibility notes (CLI flags, config schemas, versioning): None.

## Test Strategy
Seeded from issue #615:

- [ ] Unit coverage areas: focused frozen-surface digest assertion remains active and passes.
- [ ] Integration scenario to retest: Python 3.11 quality job and required CI checks pass for the resulting head SHA.
- [ ] Manual verification notes: confirm only the matching tuple changed and runtime/mirror bytes remain unchanged.

- Regression tests to add or update: No new test; run `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` against the updated expectation.
- Unit tests (pytest) for the fixed behavior and boundaries: verify both frozen-file tuples, including the unchanged `.claude/agents/epic-orchestrator.md` pin.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): preserve the existing failure behavior for missing files and mismatched digests; no new input surface is introduced.
- Error handling and logging verification: confirm mismatches remain assertion failures with actionable expected/actual digests.
- Coverage impact and targets for changed lines/modules: no production coverage change; changed test-support line is exercised by the contract test.
- Toolchain commands to run (format → lint → type-check → test): repository-required Python formatting, linting, type-checking, then pytest, followed by the focused frozen-surface contract and CI.
- Manual validation steps (if required): independently compute SHA-256 from exact runtime bytes; verify the second pin, fragment expectations, runtime skill, and mirror are unchanged.


## Acceptance Criteria
- [x] The tuple for `.claude/skills/epic-orchestrate/SKILL.md` is updated to `42cd106c1dc6982cfe4fb15fb3439bdde4eb1bbbc6a1a2db26a8739587ab4ca7`, and the focused frozen-surface contract passes.
- [x] The unchanged frozen-file pin, all section/fragment expectations, and runtime/mirror bytes remain unchanged.
- [x] The required Python format, lint, type-check, and pytest gates pass without new failures.
- [ ] CI passes for the exact resulting commit SHA, including the previously failing Python 3.11 quality job.
- [x] No production files, runtime behavior, APIs, configuration, or unrelated test-support expectations change.

## Risks & Mitigations
- Technical or operational risks: A digest copied from a different file revision could mask a frozen-document change; unrelated tuple edits could weaken coverage of another frozen surface.
- Mitigations and rollbacks: Compute the digest from exact merge-head bytes, independently cross-check it, review the one-line diff, and retain all other expectations. Revert the single tuple value if the runtime revision is rejected.

## Rollout & Follow-up
- Release/rollout steps: Implement the one-line expectation update, run the mandatory Python gates and focused contract, commit through the full-bug workflow, then verify required CI checks for the exact head SHA before release.
- Post-fix monitoring or clean-up tasks: Confirm the frozen-surface job remains green on subsequent release validation; no cleanup is expected.
- Links: https://github.com/drmoisan/drm-copilot/issues/615; CI run https://github.com/drmoisan/drm-copilot/actions/runs/33379396439
