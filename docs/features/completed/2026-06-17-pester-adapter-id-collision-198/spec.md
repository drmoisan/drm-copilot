# pester-adapter-id-collision (Spec)

- **Issue:** #198
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-17T21-05
- **Status:** Approved
- **Version:** 1.0

## Context
The VS Code Test Explorer (`pspester.pester-test` adapter) reports failing or ghost Pester items for tests that pass under `Invoke-Pester`. The adapter folds discovered test IDs to uppercase during static discovery, so sibling Describe/Context/It names — including `-ForEach`/`-TestCases` expansions — that differ only by letter case collide to a single adapter ID. The adapter then drops/misreports the duplicate.

Environment:
- OS/version: Windows, VS Code with `pspester.pester-test` 2023.7.8 and `ms-vscode.PowerShell`.
- PowerShell version: PowerShell 7 (workspace default), Pester 5.6.1.
- Command/flags used: Test Explorer "Run Tests" (adapter invokes `Scripts/PesterInterface.ps1`).
- Data source or fixture: `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Rationale: the suite is green under the engine, but the Test Explorer presents false failures, which erodes trust in the local test signal and can mask real failures.

## Repro & Evidence
Steps to Reproduce:
1. In `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`, define sibling tests whose names differ only by letter case (for example two confirmation-token cases `"YES"` and `"Yes"`).
2. Open the VS Code Test Explorer and run the file's tests.
3. Observe that one of the case-variant items is dropped or reported as failed/ghost.

Expected:
Each test discovered by the adapter has a distinct ID, and every test is reported with its true result.

Actual:
The adapter emits `Duplicate test item ... detected. ... The duplicate will be ignored.` for the two case-variant items because both fold to the uppercased ID ending `...CONFIRMTOKEN=YES`.

Logs / Screenshots:
- [x] Captured adapter discovery output
- Snippet: adapter `PesterInterface.ps1 -Discovery` emits two `type:"Test"` records with the identical `id` `...IS REJECTED WITH CODE 2>>CONFIRMTOKEN=YES`.

## Scope & Non-Goals
- In scope: disambiguate the colliding case-sensitivity cases in `Invoke-FullRelease.Tests.ps1`; add a deterministic regression guard that detects case-insensitive sibling test-name collisions across the Pester suite.
- Out of scope / non-goals: production script changes; VS Code settings changes (those are local, gitignored, and not part of this fix); changing the Pester engine or the third-party adapter.
- Explicitly excluded: any modification to `scripts/dev-tools/Invoke-FullRelease.ps1` behavior.

## Root Cause Analysis
The `pspester.pester-test` adapter constructs test IDs from uppercased Describe/Context/It names (confirmed in the adapter's discovery output, where all IDs are uppercase). When two sibling names — or two `-ForEach` expansions — differ only by letter case, their uppercased IDs are identical. The adapter's `testItemDiscoveryHandler` treats identical IDs as duplicates and ignores one. `Invoke-Pester` itself does not fold case, so the engine reports the suite green, hiding the defect from non-adapter runs.

## Proposed Fix

### Design summary (what changes where):
1. In `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`, the case-sensitivity `-ForEach` cases carry a non-case `CaseLabel` (`uppercase` / `titlecase`) that is included in the `It` name, so the uppercased IDs differ (`...(UPPERCASE)...` vs `...(TITLECASE)...`).
2. Add a deterministic regression guard test that parses every `*.Tests.ps1` via the PowerShell AST and asserts that, within each parent scope, no two static Describe/Context/It names — and no two expansions of a literal `-ForEach`/`-TestCases` hashtable array — are equal case-insensitively.

### Boundaries and invariants to preserve:
- Both confirmation-token case-sensitivity assertions remain (each verifies a non-`yes` token is rejected with exit code 2).
- No production behavior changes; test-only.
- File size stays under 500 lines.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` (disambiguation — already applied).
- New: `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1` (regression guard).

#### Functions/classes/CLI commands impacted:
- None in production.

#### Data flow and validation changes:
- The guard reads test file contents via AST only; no external process, network, or temp files.

#### Error handling and logging updates:
- The guard fails with a clear message listing the file and the colliding (case-folded) name when a collision exists.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Input: the set of `*.Tests.ps1` files under `tests/`.
- Output: Pester pass when all sibling names are case-insensitively unique; fail otherwise.

#### Backward-compatibility expectations:
- The guard only adds a test; it does not alter existing tests beyond the disambiguation.

## Assumptions, Constraints, Dependencies
- Assumptions: the adapter's uppercase ID-folding is the collision mechanism (verified from adapter output).
- Constraints: deterministic, no network/PATH/CWD/temp-file dependency (per `.claude/rules/general-unit-test.md`).
- External dependencies: none added.

## Data / API / Config Impact
- User-facing or API changes: none.
- Data or migration considerations: none.
- Logging/telemetry updates: none.
- Compatibility notes: none.

## Test Strategy
- Regression tests to add or update:
  - The disambiguation in `Invoke-FullRelease.Tests.ps1` (applied).
  - New guard `test-name-uniqueness.Tests.ps1` that fails on any case-insensitive sibling-name collision and passes when none exist.
- Edge cases and negative scenarios: a literal `-ForEach` array whose expansions collide case-insensitively must be detected; non-literal `-ForEach` arguments are skipped (documented limitation).
- Error handling verification: the guard reports the offending file and folded name.
- Coverage impact: test-only change; no production coverage regression possible.
- Toolchain commands to run: PoshQC format → analyze → test.
- Manual validation: reload VS Code window; confirm the Test Explorer reports all `Invoke-FullRelease` items.

## Acceptance Criteria
- [x] AC1: The two confirmation-token case-sensitivity cases in `Invoke-FullRelease.Tests.ps1` produce distinct adapter IDs (no duplicate-item error from the adapter). Verified: adapter discovery emits distinct IDs `...(UPPERCASE)...` and `...(TITLECASE)...`.
- [x] AC2: A new regression guard test exists that fails on a case-insensitive sibling test-name collision and passes when none exist. Path: `tests/scripts/claude-runtime/test-name-uniqueness.Tests.ps1`; helper `Get-AdapterIdCollision`; 5 tests passing.
- [x] AC3: Adapter discovery across all `tests/**/*.Tests.ps1` produces zero colliding IDs. Verified: 39 files, 608 items, 0 collisions.
- [x] AC4: No production code changed; both case-sensitivity assertions are preserved.
- [x] AC5: Full PowerShell toolchain passes (format → analyze → test) with zero new findings. Verified: full suite 604 passed / 0 failed / 9 skipped.
- [ ] AC6: CI required checks are green on the PR head. Pending PR creation and S9 CI gate.

## Risks & Mitigations
- Risk: the guard's `-ForEach` expansion logic mishandles a non-literal data argument. Mitigation: skip non-literal arguments and document the limitation; the guard still covers the literal pattern that caused this bug.
- Risk: false positives on intentionally case-distinct names. Mitigation: the comparison is scoped to siblings within one parent, matching the adapter's own ID scheme.

## Rollout & Follow-up
- Release/rollout steps: merge via PR after green CI.
- Post-fix monitoring: none required.
- Links: issue #198, PR (to be created), `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1`.
