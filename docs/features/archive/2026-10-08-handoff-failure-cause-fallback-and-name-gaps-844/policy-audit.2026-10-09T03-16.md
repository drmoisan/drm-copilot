# Policy Compliance Audit: Handoff Failure-Cause Fallback and Name Gaps (Issue #844)

- Branch: `bug/handoff-failure-cause-fallback-and-name-gaps-844`
- Head: `b27a9f8c552a9c8fcdc61c78a2279ff027558cc9`
- Base: `origin/main` at `e7d3779b398604af919678c16c877c8539a86cc0` (merge-base equals `origin/main`; diff read with `git diff origin/main...HEAD`)
- Work mode: `full-bug` (from `issue.md` marker `- Work Mode: full-bug`); AC source: `spec.md` only
- Module tier: T3 (`quality-tiers.yml` entry `extensions/drm-copilot`)
- Review timestamp: 2026-10-09T03-16 (host clock, `date +%Y-%m-%dT%H-%M`)
- Reviewer: feature-review agent

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/evidence/baseline/ts-jest-coverage.2026-10-09T03-02.md` (repo-wide 97.16% lines, 91.66% branches; per-module values for the four touched files)
- TypeScript post-change coverage artifact: `extensions/drm-copilot/coverage/lcov.info` (file mtime 03:05 local, after the last production commit `4be4a4f1` at 03:03:30) and `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/evidence/qa-gates/ts-jest-coverage.2026-10-09T03-47.md`
- PowerShell baseline coverage artifact: N/A - the branch diff contains zero PowerShell files (`.ps1`, `.psm1`, `.psd1`); PowerShell coverage does not apply to this change.
- PowerShell post-change coverage artifact: N/A - the branch diff contains zero PowerShell files; no PowerShell coverage comparison applies.
- Per-language comparison summary: section 1.2.1 of this audit and `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/evidence/qa-gates/coverage-delta.2026-10-09T03-58.md`

Template note: the MCP template-resolver tool is not in this agent's tool set. The artifact structure follows the headings and checklist lines enforced by `scripts/dev_tools/validate_policy_audit_artifact.py`.

## Executive Summary

The branch closes issue #844 and performs the #846 CR-3 split of one test file. It changes four TypeScript production modules under `extensions/drm-copilot/src/lib/validate/`, adds two test files and one test-support module, edits three existing test files, corrects two lines in the #645 feature documents, and adds the #844 feature folder.

Verified by this review:

- The diff contains TypeScript (`.ts`) and Markdown files only. No Python, PowerShell, C#, workflow, schema, fixture, or configuration file changed.
- `npm run lint` exited 0 and `npm run typecheck` (both `tsc -p ./` and `typecheck:test`) exited 0, run by this reviewer at HEAD.
- Prettier `--check` over the ten changed `.ts` files exited 0 with `All matched files use Prettier code style!`, run by this reviewer.
- A focused Jest run of `test/lib/validate/orchestration-handoff*` plus `test/mcp-handlers/orchestration-handoff-handlers.test.ts` passed 14 suites and 247 tests, run by this reviewer.
- The split test files equal the original line ranges byte-for-byte except for import and `export` keyword lines (diff against `origin/main` content, run by this reviewer). Split counts: 11 + 17 = 28, equal to the recorded pre-split count.
- `coverage/lcov.info` reports the four touched modules at 98.97/91.55, 98.99/97.73, 100.00/100.00 and 100.00/100.00 (lines/branches %). No changed production line is uncovered.
- `validate_evidence_locations.py --root <worktree>` exited 0.

Findings: 0 Blocking, 6 Non-blocking (section 8). Total blocking count: **0**. Remediation is not required.

## Rejected Scope Narrowing

No scope narrowing was applied. The caller prompt contained the following statements, each evaluated against the branch diff:

- "Language in scope: TypeScript only (extensions/drm-copilot). No PowerShell or Python changes." Accepted as factual: `git diff --name-only origin/main...HEAD` lists only `.ts` and `.md` files. It does not exclude any language with changed files.
- "PowerShell is N/A for this change; state that explicitly." Accepted: PowerShell has zero changed files on the branch, so N/A is a permitted verdict.
- "Record AC-18 as pending-PR (not a blocking finding of the code)". Accepted: the branch-diff half of AC-18 was verified independently; the PR-body half depends on an artifact that does not yet exist. This does not narrow the audit scope.

The audit scope is the full branch diff against `origin/main` (56 files, 3311 insertions, 373 deletions).

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root <worktree>` exited 0 with no output.
- `git diff --name-only origin/main...HEAD -- artifacts/` returned no paths. No file is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`.
- All 39 evidence files are under `docs/features/active/2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/evidence/{baseline,other,regression-testing,qa-gates}/`.

Result: PASS (0 location violations).

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

| Principle | Status | Evidence |
| --- | --- | --- |
| Independence | PASS | Each case builds its own scenario via `createScenario`; no shared mutable state across cases in the new or edited files. |
| Isolation | PASS | F1-F3 test the pure helper; F4 tests the production validator; F5-F7 test the materializer through injected dependencies. |
| Fast execution | PASS | Focused run of 14 handoff suites completed in under 1 s. |
| Determinism | PASS | `evidence/qa-gates/test-purity.2026-10-09T03-59.md`: zero matches for `jest.mock`, `tmpdir`, `mkdtemp`, `writeFileSync`, `Date.now`, `setTimeout`, `Math.random` across the six test files. |
| Readability | PASS | Cases carry row identifiers (F1-F7, A7, h-j) and Arrange/Act/Assert comments. |

### 1.2 Coverage and Scenarios

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
| --- | --- | --- | --- | --- | --- | --- |
| TypeScript | 10 (4 src, 6 test) | 3917 | PASS (256 suites) | 97.16% lines / 91.66% branches | 97.16% lines / 91.70% branches | 100% (58/58 added production lines covered) |
| PowerShell | 0 | N/A | N/A | N/A | N/A | N/A |
| Python | 0 | N/A | N/A | N/A | N/A | N/A |
| C# | 0 | N/A | N/A | N/A | N/A | N/A |

Per-file results for modified production files (no production file was added):

| File | Baseline lines / branches | Post-change lines / branches | Threshold result |
| --- | --- | --- | --- |
| `src/lib/validate/orchestration-handoff-authority-service.ts` | 98.97% / 90.14% | 98.97% / 91.55% | PASS |
| `src/lib/validate/orchestration-handoff-materializer.ts` | 98.98% / 96.43% | 98.99% / 97.73% | PASS |
| `src/lib/validate/orchestration-handoff-materializer-production.ts` | 100.00% / 97.50% | 100.00% / 100.00% | PASS |
| `src/lib/validate/orchestration-handoff-materializer-request.ts` | 100.00% / 100.00% | 100.00% / 100.00% | PASS |

Post-change values were re-read by this reviewer from `extensions/drm-copilot/coverage/lcov.info` (LH/LF, BRH/BRF records). Repo-wide totals recomputed from the same file: 51037/52524 lines and 7520/8200 branches. A scan of `DA:` records with zero hits in the four modules returned lines 59, 60, 79, 80 (authority-service) and 216-220 (materializer); none of these is a changed line.

Scenario completeness: positive (identifier name, contract error code), negative (non-identifier name, empty name, non-`Error` value, malformed JSON), and both arms of each new ternary are exercised.

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.16% lines / 91.66% branches repo-wide (authority-service 98.97%/90.14%, materializer 98.98%/96.43%, materializer-production 100.00%/97.50%, materializer-request 100.00%/100.00%). Post-change: 97.16% lines / 91.70% branches repo-wide (98.97%/91.55%, 98.99%/97.73%, 100.00%/100.00%, 100.00%/100.00%). Change: +0.00 pp lines and +0.04 pp branches repo-wide; no module regressed, branch coverage rose in three modules. New/changed-code coverage: 100% (58 of 58 added production lines have a DA record with hits greater than zero). Disposition: PASS. Evidence: `extensions/drm-copilot/coverage/lcov.info`, `evidence/baseline/ts-jest-coverage.2026-10-09T03-02.md`, `evidence/qa-gates/ts-jest-coverage.2026-10-09T03-47.md`, `evidence/qa-gates/coverage-delta.2026-10-09T03-58.md`.
- PowerShell: N/A. Zero PowerShell files changed on the branch. Disposition: N/A.

### 1.3 Test Structure and Diagnostics

PASS. New cases follow Arrange/Act/Assert. Table-driven cases use `it.each` with a `$label` title. Assertions compare exact cause strings, so a failure message shows the expected and received token.

### 1.4 External Dependencies and Environment

PASS. F4 uses an in-memory `FileSystem` object (`satisfies FileSystem`) and a stub `CommandRunner`. No network, subprocess, or temporary file is used. The authority-service support module reads fixture JSON with `readFileSync`, unchanged from the pre-split file.

### 1.5 Policy Audit Requirement

PASS. This artifact is the policy audit for the branch.

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

PASS. `evidence/baseline/phase0-instructions-read.2026-10-09T02-52.md` records the policy reading order; baseline gates were captured in `evidence/baseline/`.

### 2.2 Design Principles

PASS. `describeEnvelopeParseFailure` is a pure function that removes the duplicated `instanceof HandoffContractError` ternary from two call sites (reusability) and makes the fallback arm testable without module mocks. The validation-result pass-through adds one optional field. No new class or abstraction was introduced.

### 2.3 Module and File Structure

PASS. Line counts at HEAD (`wc -l`, run by this reviewer): materializer.ts 494, authority-service.ts 390, materializer-request.ts 155, materializer-production.ts 138; test files 469, 193, 179, 179, 170, 154. All are at or below 500. The test-support module is in `test/`, not `src/`.

### 2.4 Naming, Docs, and Comments

PASS. New exported function and constant carry TSDoc. The `describeHandoffFailureCause` docstring was updated to state the name constraint.

### 2.5 After Making Changes - Toolchain Execution

| Stage | Result | Evidence |
| --- | --- | --- |
| 1 Format | PASS | `evidence/qa-gates/ts-prettier.2026-10-09T03-43.md`; reviewer re-run on changed files exited 0 |
| 2 Lint | PASS | `evidence/qa-gates/ts-eslint.2026-10-09T03-44.md`; reviewer `npm run lint` exited 0 |
| 3 Type check | PASS | `evidence/qa-gates/ts-typecheck*.2026-10-09T03-44.md`; reviewer `npm run typecheck` exited 0 |
| 4 Architecture boundary | Not configured | `evidence/qa-gates/architecture-boundary.2026-10-09T03-45.md` (no dependency-cruiser config) |
| 5 Unit tests and coverage | PASS | `evidence/qa-gates/ts-jest-coverage.2026-10-09T03-47.md` (256 suites, 3917 tests) |
| 6 Contract / schema | PASS | `evidence/qa-gates/contract-schema-unchanged.2026-10-09T03-48.md`; reviewer diff of schema, config, fixtures, MCP definitions is empty |
| 7 Integration | PASS | MCP handler suite ran in stage 5 and in the reviewer focused run |

Single-pass certification: `evidence/qa-gates/toolchain-loop-single-pass.2026-10-09T03-49.md` (12 file hashes unchanged across the pass).

### 2.6 Summarize and Document

PASS. Plan deviations are recorded in `plan.2026-10-08T23-42.md` under `## Plan Deviations (execution)` (three items). AC status summary is in `evidence/other/ac-status-summary.2026-10-09T04-02.md`.

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: Python Code Change Policy Compliance

N/A. Zero Python files changed.

### Section 3B: PowerShell Code Change Policy Compliance

N/A. Zero PowerShell files changed.

### Section 3C: C# Code Change Policy Compliance

N/A. Zero C# files changed.

### Section 3E: TypeScript Code Change Policy Compliance

| Rule | Status | Evidence |
| --- | --- | --- |
| Prettier, ESLint, TSC clean | PASS | Section 2.5 |
| Avoid `any`; prefer `unknown` plus narrowing | PASS | New helper takes `error: unknown`; no `any` added |
| Avoid type assertions unless justified | PARTIAL (Non-blocking) | Test F6 uses `undefined as unknown as HandoffEnvelope["lifecycle"]` without a justification comment (finding NB-2) |
| `exactOptionalPropertyTypes` compatibility | PASS | `blockedResult` option widened to `string \| undefined`; conditional spread omits `undefined` |
| No new import cycle | PASS | `orchestration-handoff-contract-support.ts` has no imports; `HandoffContractError` is re-exported from `orchestration-handoff-contract.ts:34`, so `instanceof` identity is unchanged |
| T3 untyped escape hatches (<= 5 per file, justified) | PASS | One double assertion in one test file; zero in production |

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: Python Unit Test Policy Compliance

N/A. Zero Python files changed.

### Section 4B: PowerShell Unit Test Policy Compliance

N/A. Zero PowerShell files changed.

### Section 4C: TypeScript Unit Test Policy Compliance

PASS. Jest with `@jest/globals` imports; test files under `test/lib/validate/` mirror `src/lib/validate/`; the support module name does not match `testMatch` (`**/test/**/*.test.ts`) and is not in `collectCoverageFrom` (`src/**/*.ts`). Per-file `coverageThreshold` entries for all four touched modules exist at `jest.config.cjs:413-441`; no production file was added, so no new entry is required. Property-based tests are not required at T3.

## 5. Test Coverage Detail

### describeEnvelopeParseFailure (3 tests, new file)

- F1 `HandoffContractError` keeps code `HANDOFF_HISTORY_INVALID`; cause `envelope-parse: HANDOFF_HISTORY_INVALID`.
- F2 `TypeError` maps to `HANDOFF_UNSUPPORTED_VERSION`; cause `envelope-parse: TypeError`.
- F3 thrown string maps to `HANDOFF_UNSUPPORTED_VERSION`; cause `envelope-parse: non-error value`.

### Pass-through and projection (4 tests, new file)

- F4 production `validateEnvelope("{")` returns `failureCause: "envelope-parse: HANDOFF_UNSUPPORTED_VERSION"`.
- F5 materializer forwards a validator `failureCause` to the blocked result.
- F6 projection no-`code` arm: `HANDOFF_VALIDATOR_UNAVAILABLE`, `destination-projection: TypeError`.
- F7 projection code arm: `HANDOFF_UNSUPPORTED_VERSION`, `destination-projection: HANDOFF_UNSUPPORTED_VERSION`.

### describeHandoffFailureCause name guard (3 rows added)

- (h) `"Bad Name: /home/operator"` gives `checkpoint-read: Error`.
- (i) `"CustomFailure"` gives `checkpoint-read: CustomFailure` (positive control).
- (j) `""` gives `checkpoint-read: Error`.

### Authority envelope-parse (1 row added)

- A7 `envelopeText: "{"` gives `HANDOFF_UNSUPPORTED_VERSION` and `envelope-parse: HANDOFF_UNSUPPORTED_VERSION`.

### Authority-service split (28 tests moved, 0 added)

- `orchestration-handoff-authority-service.test.ts`: 11 tests; `orchestration-handoff-authority-service-binding.test.ts`: 17 tests (reviewer focused runs).

## 6. Test Execution Metrics

| Run | Suites | Tests | Result | Source |
| --- | --- | --- | --- | --- |
| Baseline full coverage | 254 | 3906 | PASS | `evidence/baseline/ts-jest-coverage.2026-10-09T03-02.md` |
| Regression-first before fix | 3 | 10 failed / 35 passed | Expected failure | `evidence/regression-testing/regression-first-before-fix.2026-10-09T03-25.md` |
| Regression-first after fix | 3 | 45 | PASS | `evidence/regression-testing/regression-first-after-fix.2026-10-09T03-36.md` |
| Final full coverage | 256 | 3917 | PASS | `evidence/qa-gates/ts-jest-coverage.2026-10-09T03-47.md` |
| Reviewer focused run (handoff + MCP handler) | 14 | 247 | PASS | this review |

Test delta: +11 tests (h, i, j, A7, F1-F7); +2 suites (fallback, binding).

## 7. Code Quality Checks

| Check | Result |
| --- | --- |
| File size (<= 500 lines) | PASS; largest changed file 494 lines |
| Error handling (no silent swallow) | PASS; every changed catch returns a blocked result with a cause |
| Redaction (no message or stack in cause) | PASS; tokens are limited to pattern-checked `code`, pattern-checked `name`, or fixed literals |
| Behavior invariants (status, primary code, paths unchanged) | PASS; codes are unchanged at every changed site; only the optional cause field is added |
| Out-of-scope files unchanged | PASS; reviewer diff of `subagent-tree-command.test.ts`, `orchestration-handoff-contract.ts`, changelogs, `config/`, `resources/`, MCP tool definitions, fixtures, `jest.config.cjs`, `package.json` is empty |

## 8. Gaps and Exceptions

### Identified Gaps

| ID | Severity | Finding | Recommendation |
| --- | --- | --- | --- |
| NB-1 | Non-blocking | Evidence file timestamps are not host-clock values. 37 of 39 evidence files carry a filename timestamp later than the commit that added them (for example `ac-status-summary.2026-10-09T04-02.md` in commit `b27a9f8c` at 03:10; `ts-jest-coverage.2026-10-09T03-47.md` in commit `a176cfc8` at 03:06). The host clock read 03:16 at review time. `evidence-and-timestamp-conventions` states the timestamp is read from the host clock and never composed. | Read timestamps with `date +%Y-%m-%dT%H-%M` or `Get-Date` at record time. The gate results that AC check-off depends on (lint, typecheck, format, focused tests, split counts, per-file coverage) were re-verified by this reviewer, so the timestamp defect does not change any verdict. |
| NB-2 | Non-blocking | `orchestration-handoff-failure-cause-fallback.test.ts` F6 uses `undefined as unknown as HandoffEnvelope["lifecycle"]` without a justification comment. | Add a one-line comment stating the cast forces the no-`code` `TypeError` arm. |
| NB-3 | Non-blocking | `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in the worktree, and the PR-context collector MCP tool is not in this agent's tool set. | The review used `git diff origin/main...HEAD` directly as the equivalent source. Refresh PR context before PR authoring. |
| NB-4 | Non-blocking | `issue.md` line 5 records `Promoted -> docs/features/active/handoff-failure-cause-fallback-and-name-gaps/`, which differs from the actual folder `2026-10-08-handoff-failure-cause-fallback-and-name-gaps-844/`. | Correct the path when the folder moves to `completed/`. |
| NB-5 | Non-blocking | AC-14 to AC-17 name `npm run` scripts; the evidence records the equivalent `npx` commands (`npx eslint ...`, `npx tsc ...`, `npx jest --config jest.config.cjs ...`). `package.json` scripts resolve to the same commands; `run-jest.cjs` adds only a prohibited-flag guard. | No action required; the reviewer ran `npm run lint` and `npm run typecheck` directly and both exited 0. |
| NB-6 | Non-blocking | AC-18 PR-body half (closing keyword for #844, non-closing reference to #846) cannot be verified until the PR exists. | Orchestrator checks AC-18 after PR creation (plan task P7-T18). |

Blocking findings: 0.

### Approved Exceptions

None.

### Removed/Skipped Tests

None. The split moved 28 tests without removal; the post-split sum equals the pre-split count.

## 9. Summary of Changes

### Commits in This PR/Branch

- `742f6775` docs(844): prepare feature folder, research, spec, and preflight-cleared plan
- `07784198` docs(844): record phase 0 baseline evidence
- `59d4e2ba` test(846): split orchestration-handoff-authority-service tests into support and binding files
- `67c747b0` docs(844): record phase 1 split evidence
- `75a653a4` test(844): add failing regression tests for failure-cause fallback and name gaps
- `4be4a4f1` fix(844): carry failure causes for envelope-parse and projection failures and guard error names
- `f52cde9c` docs(844): correct #645 AC-8 and US-1 test-file references
- `a176cfc8` docs(844): record phase 5 final QC evidence
- `bea2481a` docs(844): record phase 6 scope, inventory, and coverage-delta evidence
- `b27a9f8c` docs(844): check off AC-1 through AC-17 and record AC status summary

### Files Modified

- Production (modified): `orchestration-handoff-authority-service.ts`, `orchestration-handoff-materializer.ts`, `orchestration-handoff-materializer-production.ts`, `orchestration-handoff-materializer-request.ts`.
- Tests (added): `orchestration-handoff-failure-cause-fallback.test.ts`, `orchestration-handoff-authority-service-binding.test.ts`, `orchestration-handoff-authority-service-test-support.ts`.
- Tests (modified): `orchestration-handoff-authority-service.test.ts`, `orchestration-handoff-failure-cause.test.ts`, `orchestration-handoff-failure-cause-authority.test.ts`.
- Documentation: #645 `spec.md` (AC-8 line), #645 `user-story.md` (US-1 line), #844 feature folder, promoted lifecycle record.

## 10. Compliance Verdict

### Overall Status: COMPLIANT (0 Blocking, 6 Non-blocking)

### Policy-by-Policy Summary

- General Code Change Policy (Section 2): PASS.
- Language-Specific Code Change Policy (Section 3): TypeScript PASS with one Non-blocking note (NB-2); Python, PowerShell, C# N/A (zero changed files).
- General Unit Test Policy (Section 1): PASS; TypeScript coverage PASS.
- Language-Specific Unit Test Policy (Section 4): TypeScript PASS; others N/A.
- Evidence Location Compliance: PASS.

### Metrics Summary

- Repo-wide TypeScript: 97.16% lines, 91.70% branches (thresholds 85% / 75%).
- Changed production lines covered: 58/58.
- Tests: 3917 passed, 0 failed.
- Total blocking count: 0.

### Recommendation

Proceed to PR authoring. Address NB-1 and NB-2 at the next opportunity; they do not affect behavior or verification results.

## Appendix A: Test Inventory

- `test/lib/validate/orchestration-handoff-failure-cause-fallback.test.ts`: F1, F2, F3 (`describeEnvelopeParseFailure`); F4, F5 (pass-through); F6, F7 (projection).
- `test/lib/validate/orchestration-handoff-failure-cause.test.ts`: existing rows (a)-(g), redaction case, M1-M17, B1, B2, P1; added rows (h), (i), (j).
- `test/lib/validate/orchestration-handoff-failure-cause-authority.test.ts`: existing A1-A6; added A7.
- `test/lib/validate/orchestration-handoff-authority-service.test.ts`: 11 existing tests (moved bodies unchanged).
- `test/lib/validate/orchestration-handoff-authority-service-binding.test.ts`: 17 existing tests (moved bodies unchanged).
- `test/lib/validate/orchestration-handoff-authority-service-test-support.ts`: shared fixtures and `createScenario` (not a suite).

## Appendix B: Toolchain Commands Reference

Commands run by this reviewer (worktree root unless noted):

```text
git diff --stat origin/main...HEAD
git diff --name-status origin/main...HEAD
git diff origin/main...HEAD -- extensions/drm-copilot/src docs/features/active/2026-09-07-portable-handoff-614-review-follow-ups-645
git log --oneline origin/main..HEAD --name-only -- extensions/
git show origin/main:extensions/drm-copilot/test/lib/validate/orchestration-handoff-authority-service.test.ts  (saved to scratchpad; compared with diff against the three split files)
npm --prefix extensions/drm-copilot run lint                       -> exit 0
npm --prefix extensions/drm-copilot run typecheck                  -> exit 0
node extensions/drm-copilot/node_modules/prettier/bin/prettier.cjs --check <10 changed .ts files>  -> exit 0
npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestration-handoff test/mcp-handlers/orchestration-handoff-handlers.test.ts  -> 14 suites, 247 tests passed
npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestration-handoff-authority-service.test.ts          -> 11 passed
npm --prefix extensions/drm-copilot run test:unit -- test/lib/validate/orchestration-handoff-authority-service-binding.test.ts  -> 17 passed
awk over extensions/drm-copilot/coverage/lcov.info (LF/LH/BRF/BRH, DA zero-hit, BRDA zero-hit for the four modules)
python scripts/dev_tools/validate_evidence_locations.py --root <worktree>  -> exit 0
git diff --stat origin/main...HEAD -- <out-of-scope paths>          -> empty
```

Executor commands (from evidence):

```text
npx prettier --check "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"
npx eslint --no-error-on-unmatched-pattern src test
npx tsc -p ./ --noEmit
npx tsc -p tsconfig.jest.json --noEmit
npx jest --config jest.config.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary
```
