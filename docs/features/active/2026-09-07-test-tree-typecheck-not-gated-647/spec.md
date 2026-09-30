# 2026-09-07-test-tree-typecheck-not-gated (Spec)

- **Issue:** #647
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T20-10
- **Status:** Draft
- **Version:** 0.1

## Context
The extension's TypeScript test tree is never type-checked by any enforced gate. `npm run typecheck` compiles `src/**/*.ts` only, and ts-jest runs under `isolatedModules: true`, which suppresses diagnostics. `tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`, the only configuration that includes `test/**/*.ts`, exits 2 with 331 `error TS` lines across 69 files at main.

Environment:
- OS/version: Windows 11 Pro 10.0.26200; also reproduced by the #614 feature review at branch head 645c40b0
- Python version: not applicable
- Command/flags used: `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`
- Data source or fixture: repository at `main` (c3ffb080 or later); `extensions/drm-copilot/tsconfig.json` line 23 `"include": ["src/**/*.ts"]`, `tsconfig.jest.json` line 8 `"include": ["src/**/*.ts", "test/**/*.ts"]`, `package.json` line 209 `"typecheck": "tsc -p ./ --noEmit"`

Impact / Severity:
- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Type errors in tests do not fail CI, so test code can drift from production types (for example a request literal missing newly required fields while the suite still passes, as R20 of the #614 review shows). Coverage and behavior gates still hold, so this is a quality-durability gap rather than a shipped defect.


## Repro & Evidence
Steps to Reproduce:
1. From the repository root run `npm --prefix extensions/drm-copilot run typecheck`; observe exit 0 with no output.
2. Run `node extensions/drm-copilot/node_modules/typescript/bin/tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit`.
3. Observe exit code 2 and 331 `error TS` diagnostics across 69 test files (for example `error TS2740` at `test/lib/validate/orchestration-handoff-materializer-path-boundary.test.ts(182,9)`, missing-member errors on `VirtualFileSystem` against newer `FileSystem` members, `noPropertyAccessFromIndexSignature` accesses, and Jest mock-typing mismatches).

Expected:
Either the test tree type-checks cleanly and a CI gate enforces it (the repository's TypeScript policy requires the type-check stage of the toolchain loop and treats untyped escape hatches as tier-gated), or the repository explicitly documents that test files are exempt from type checking and why. A plan gate of "the test tree type-checks with exit 0" is currently unsatisfiable at baseline, which the #614 CI remediation plan had to work around by gating on "no diagnostic absent from the baseline set".

Actual:
`npm run typecheck` reports success while the test tree carries 331 type errors; none of the CI jobs (`quality-checks`, `drm-copilot-extension-tests`, `root-typescript-tests`) fails on them because Jest transpiles without diagnostics. Of the 331 errors, 318 sit in 63 files untouched by recent feature work, so this is a repository-wide accumulation rather than a single regression.

Logs / Screenshots:
- [x] Attached minimal logs or screenshot
- Snippet: recorded in `docs/features/completed/2026-08-31-portable-prepared-orchestration-handoff-614/evidence/remediation-baseline/typescript-test-tree-typecheck.2026-09-07T03-16.md` (full diagnostic list at head fca8c045) and in `policy-audit.2026-09-07T08-00.md`, out-of-scope observation 3.


## Scope & Non-Goals
- In scope:
- Out of scope / non-goals:
- Explicitly excluded systems, integrations, or datasets:

## Root Cause Analysis
`tsconfig.json` was scoped to `src` to keep the production build clean, and `tsconfig.jest.json` was added for ts-jest module resolution rather than as a gate. `isolatedModules: true` in `tsconfig.jest.json` makes ts-jest skip type checking. No workflow invokes `tsc` against `tsconfig.jest.json`. Repository-level decision needed: gate the test tree (and fix or suppress the 331 errors, with suppressions governed by the TypeScript suppression policy) or record the exemption in `.claude/rules/typescript.md` and the TypeScript instructions.


## Proposed Fix

### Design summary (what changes where):

### Boundaries and invariants to preserve:

### Dependencies or blocked work:

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:

#### Functions/classes/CLI commands impacted:

#### Data flow and validation changes:

#### Error handling and logging updates:

#### Rollback/feature-flag considerations (if applicable):

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

#### Required configuration keys and defaults:

#### Backward-compatibility expectations:

#### Performance constraints (latency/throughput/memory):

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
- Constraints (budget, performance, compatibility):
- External dependencies (services, libraries, releases):

## Data / API / Config Impact
- User-facing or API changes:
- Data or migration considerations:
- Logging/telemetry updates (if any):
- Compatibility notes (CLI flags, config schemas, versioning):

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: not applicable (type-level).
- [x] Integration scenario to retest: add a CI step (or extend `typecheck`) that runs `tsc -p tsconfig.jest.json --noEmit` and fails on any diagnostic once the backlog is cleared; until then, a ratchet that fails only on diagnostics absent from a committed baseline.
- [x] Manual verification notes: after the fix, `tsc -p extensions/drm-copilot/tsconfig.jest.json --noEmit` exits 0 on `main`.

- Regression tests to add or update:
- Unit tests (pytest) for the fixed behavior and boundaries:
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
- Error handling and logging verification:
- Coverage impact and targets for changed lines/modules:
- Toolchain commands to run (format → lint → type-check → test):
- Manual validation steps (if required):


## Acceptance Criteria
- [ ] Repro steps now produce the expected behavior in all documented environments.
- [ ] Regression test(s) added and passing (list file path and test name).
- [ ] Edge cases and invalid inputs are handled with correct errors or fallbacks.
- [ ] No unintended behavior changes outside the defined scope.
- [ ] Required logs/telemetry updated and validated (if applicable).
- [ ] Performance constraints met or explicitly waived with rationale.
- [ ] Full toolchain pass completed (format → lint → type-check → test).
- [ ] Docs/config references updated to match the new behavior.

## Risks & Mitigations
- Technical or operational risks:
- Mitigations and rollbacks:

## Rollout & Follow-up
- Release/rollout steps:
- Post-fix monitoring or clean-up tasks:
- Links: issue, PRs, related docs
