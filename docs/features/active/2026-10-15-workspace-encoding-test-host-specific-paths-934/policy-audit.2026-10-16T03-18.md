# Policy Compliance Audit: Issue #934 — workspace-encoding test host-specific paths (remediation cycle 1 re-audit)

- Issue: #934
- Branch: `bug/workspace-encoding-test-host-specific-paths-934`
- Head: `735a60d825fc49de4919ad845c40db90540d52c0` (includes merge of `origin/main` at `97559c3e0`)
- Resolved base: `origin/main` at `97559c3e0dcfceb807ae330d3c9e6ae4c5d67964` (merge base equals `origin/main`; the branch is current with base)
- Work mode: `minor-audit` (from `issue.md` line 12)
- Review timestamp (UTC): 2026-10-16T03-18
- Review type: re-audit at remediation cycle 1 exit. Prior review set: `policy-audit.2026-10-16T01-25.md`, `code-review.2026-10-16T01-25.md`, `feature-audit.2026-10-16T01-25.md`, `remediation-inputs.2026-10-16T01-25.md` (blocking B1; non-blocking N1-N5). The prior artifacts are unchanged since commit `3fc0e86c8` (reviewer `git diff --name-only 3fc0e86c8 HEAD` on the four files: empty).
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` were stale (head `9fcf0909e`). The reviewer regenerated them with `python -m scripts.dev_tools.pr_context.collector --base origin/main`. Both now carry generation time `2026-10-16 03:22:23 UTC`, `Head SHA: 735a60d8...`, and merge base `97559c3e0...`. The summary lists 85 changed files: 0 core logic, 85 docs/templates/tests (83 feature-folder Markdown files and 2 TypeScript test files).

## Total Blocking Findings: 0

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: Jest text-reporter log `SCRATCH/issue-934/jest-coverage-rem-baseline.log` (untracked; read by the reviewer), summarized in `evidence/remediation-baseline/jest-coverage.2026-10-16T02-48.md`
- TypeScript post-change coverage artifact: Jest text-reporter log `SCRATCH/issue-934/jest-coverage-rem-final.log` (untracked; read by the reviewer), summarized in `evidence/qa-gates/rem-jest-coverage.2026-10-16T03-07.md` and `evidence/qa-gates/rem-coverage-delta.2026-10-16T03-07.md`
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed on the branch
- Per-language comparison summary: section 1.2.1 of this document

## Executive Summary

Remediation cycle 1 resolved the single blocking finding from the 01-25 review. B1 is resolved: the research artifact no longer contains any drive-letter absolute path, encoded absolute host directory name, or host user segment inside a path; the removed literals were replaced with `<drive>`, `<drive-lowercase>`, and `<host-user>` placeholders. N5 is fixed: `issue.md` line 5 now names the actual feature folder. N1 is applied: `encodedNameOf` takes only `...segments` and uses `UPPER_DRIVE` internally, and AC-2 and AC-4 continue to hold.

The branch diff against `origin/main` contains no production file (`git diff origin/main --name-only -- extensions/drm-copilot/src`: empty). The merge of `origin/main` at `735a60d82` changed only `.github/dependabot.yml`, one Python test file from main, and issue #940 feature documents; it touched nothing under `extensions/drm-copilot`, so the TypeScript QA evidence recorded at `c71a1d242` applies to the reviewed head. Prettier, ESLint, both `tsc` configurations, the per-file Jest runs (9/9 and 12/12), and the full coverage run (270 suites, 4002 tests) pass, and coverage is unchanged from the remediation baseline.

Blocking findings: 0. Non-blocking observations: 5 (R1-R5).

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The caller prompt requested a full re-audit with specific verification targets (B1, N5, N1, AC-1 through AC-6, production diff, coverage). The reviewer audited the full branch diff (`git diff --name-status origin/main...HEAD`, 85 paths). No exclusion of any language or toolchain stage was requested.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root .` (run through `poetry run`): exit 0, no output.
- Branch-diff scan for paths under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero matches.
- All evidence files on the branch are under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/remediation-baseline/`, `<FEATURE>/evidence/qa-gates/`, or `<FEATURE>/evidence/other/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred in this review.

Verdict: PASS.

## Prior Finding Disposition

| ID | Prior severity | Status | Reviewer verification |
|---|---|---|---|
| B1 | Blocking | Resolved | `grep -rnE '[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[A-Za-z]'` over the feature folder and both test files: exit 1, no output. A broader drive-letter search (`[A-Za-z]:[\\/]` followed by a letter) over the feature folder returns only synthetic one-letter examples (`C:\a` and `C:a` in research lines 11 and 72, `C:/x` and `C:\\x` in plan lines 108-109); none contains a user segment. Encoded-name search (`[A-Za-z]--[A-Za-z]` at a token boundary) returns only `C--a`, `C--x`, the generic `C--Users-...` prefix mention on research line 47, and placeholder forms beginning with `<drive>`. Research lines 55 and 107-111 now hold placeholders. Searches for POSIX-style drive mounts, `AppData`, 8.3 short names, and agent-worktree paths in the feature folder and both test files: no match. |
| N1 | Non-blocking | Applied | `workspace-encoding.test.ts` line 21: `function encodedNameOf(...segments: string[]): string`; line 22 builds the name from `UPPER_DRIVE`. The helper body references neither `encodeWorkspacePath` nor `workspacePathOf`. |
| N2 | Non-blocking | No action (decision D6) | Unchanged; acceptable. |
| N3 | Non-blocking | No action (decision D6) | Carried forward as R3. |
| N4 | Non-blocking | No action (decision D6) | Pre-existing convention; unchanged. |
| N5 | Non-blocking | Fixed | `issue.md` line 5 reads `Promoted -> docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/ (Issue #934)`. |

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

- Independence and isolation: each test builds inputs from module-level immutable constants and two pure helpers; no shared mutable state. PASS.
- Fast execution and determinism: no clock, RNG, timer, network, or filesystem use. The only added import is `node:path`, used for its `sep` constants. PASS.
- Readability: helper names and the line comments on lines 15 and 20 state the purpose of each helper. PASS.

### 1.2 Coverage and Scenarios

Thresholds: the root `CLAUDE.md` states no coverage thresholds, so the defaults govern (line >= 85%, branch >= 75%).

| Language | Files Changed | Tests | Test Result | Baseline Coverage | Post-Change Coverage | New Code Coverage |
|---|---|---|---|---|---|---|
| TypeScript | 2 (test files only) | 4002 (full run); 9 + 12 in touched files | PASS | 97.26% lines / 92.28% branch | 97.26% lines / 92.28% branch | N/A - no production lines changed |
| Python | 0 | n/a | n/a | N/A | N/A | N/A |
| PowerShell | 0 | n/a | n/a | N/A | N/A | N/A |
| C# | 0 | n/a | n/a | N/A | N/A | N/A |

Scenario completeness: the covered input shapes are preserved (backslash and forward-slash separators, uppercase input versus lowercase on-disk directory, `-wt-` worktree and nested worktree suffixes, unrelated-suffix rejection, other-repository rejection, empty result, session-id validation, not-found error). PASS.

### 1.2.1 Per-Language Coverage Comparison

- TypeScript: Baseline: 97.26% lines / 92.28% branch -> Post-change: 97.26% lines / 92.28% branch. Change: none (0.00 points). Exercised modules: `src/lib/subagent-tree/workspace-encoding.ts` 100% lines / 100% branch before and after; `src/lib/subagent-tree/session-transcript-resolver.ts` 100% lines / 85.71% branch before and after. No production line changed, so changed-line coverage has no denominator. Repo-wide, new-file, and modified-file thresholds are met. Disposition: PASS. Evidence: `SCRATCH/issue-934/jest-coverage-rem-baseline.log`, `SCRATCH/issue-934/jest-coverage-rem-final.log`, `evidence/remediation-baseline/jest-coverage.2026-10-16T02-48.md`, `evidence/qa-gates/rem-jest-coverage.2026-10-16T03-07.md`, `evidence/qa-gates/rem-coverage-delta.2026-10-16T03-07.md`.
- Python: N/A - no changed files on the branch.
- PowerShell: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

The reviewer extracted the `All files`, `workspace-encoding.ts`, and `session-transcript-resolver.ts` rows from both raw logs with `grep`; the values match the committed evidence. The final log reports `Test Suites: 270 passed, 270 total` and `Tests: 4002 passed, 4002 total`, and no line contains `coverage threshold`. `jest.config.cjs` is not modified on the branch, so no coverage `exclude` entry was added.

### 1.3 Test Structure and Diagnostics

Every test keeps its `// Arrange`, `// Act`, `// Assert` comments. Assertions use `toBe` and `toEqual`; Jest prints both sides on failure. PASS.

### 1.4 External Dependencies and Environment

Neither test file creates temporary files or reads the real filesystem; the session-transcript tests use the existing `InMemoryFileSystem` fake. PASS.

### 1.5 Policy Audit Requirement

This document is the policy audit for the branch at cycle 1 exit. PASS.

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

`evidence/remediation-baseline/phase0-instructions-read.2026-10-16T02-40.md` records the policy reading order for the cycle; remediation-baseline evidence for tests, coverage, line counts, host-path lines, the N1 parameter, and the N5 status line was captured before the cycle edits. PASS.

### 2.2 Design Principles

N1 removed the single-valued `drive` parameter, which simplifies the helper. PASS.

### 2.3 Module & File Structure

Reviewer `wc -l` at head: `workspace-encoding.test.ts` 198 lines (219 before N1), `session-transcript-resolver.test.ts` 152 lines; both are under 500. Production files changed: 0. PASS.

### 2.4 Naming, Docs, and Comments

Constants use `UPPER_SNAKE_CASE`, helpers use `camelCase`. PASS.

### 2.5 After Making Changes - Toolchain Execution

`evidence/qa-gates/rem-end-state-summary.2026-10-16T03-12.md` records the final QC loop (P2-T1 through P2-T8) passing in a single pass. Stages 4 (architecture), 6 (contract), and 7 (integration) have no input in a test-only change. PASS.

### 2.6 Summarize and Document

The remediation plan, decisions (D1-D7), and evidence exist in the feature folder. The B1 redaction is complete. Retained bare-token prose in the research artifact is recorded as R1 (non-blocking). PASS.

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: TypeScript Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

Prettier, ESLint, and both `tsc` configurations were run at the remediation baseline (`evidence/remediation-baseline/*.2026-10-16T02-45.md`). PASS.

#### 3A.2 Types and Safety

The helpers have explicit parameter and return types. Reviewer search for `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, and `@ts-nocheck` in both files: no match. `extensions/drm-copilot` is tier T3 in `quality-tiers.yml`; zero escape hatches satisfies the T3 limit, and T3 requires no property tests. PASS.

#### 3A.3 Structure, Naming, and Comments

Imports use `node:path`, matching the extension's existing style. PASS.

#### 3A.4 Running the Toolchain

`evidence/qa-gates/rem-prettier-check.2026-10-16T03-04.md`, `rem-eslint.2026-10-16T03-04.md`, `rem-tsc-src.2026-10-16T03-04.md`, and `rem-tsc-jest.2026-10-16T03-04.md` record exit 0 with no errors. The reviewer did not rerun these commands; the merge commit changed no file under `extensions/drm-copilot`, so the results apply to head. PASS.

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: TypeScript Unit Test Policy Compliance

#### 4A.1 Framework and Scope

Jest with `@jest/globals` imports, unchanged. PASS.

#### 4A.2 Test Style and Structure

Arrange-Act-Assert preserved in all tests. PASS.

#### 4A.3 Naming and Readability

All test titles are unchanged; `evidence/qa-gates/rem-jest-workspace-encoding.2026-10-16T03-06.md` and `rem-jest-session-transcript-resolver.2026-10-16T03-06.md` record title lists identical to baseline. PASS.

#### 4A.4 Running the Toolchain

The reviewer read the Jest JSON results: `jest-we-rem-final.json` 9 passed of 9, `jest-str-rem-final.json` 12 passed of 12, matching the original baselines (9 and 12). Full coverage run: 270/270 suites, 4002/4002 tests. PASS.

## 5. Test Coverage Detail

### src/lib/subagent-tree/workspace-encoding.ts (exercised by 9 tests) — 100% lines, 100% branch

Unchanged from baseline. Production file not modified.

### src/lib/subagent-tree/session-transcript-resolver.ts (exercised by 12 tests) — 100% lines, 85.71% branch

Unchanged from baseline; the uncovered branch at line 71 is pre-existing. Production file not modified.

## 6. Test Execution Metrics

| Metric | Value | Status |
|---|---|---|
| `workspace-encoding.test.ts` tests | 9 passed / 9 (baseline 9) | PASS |
| `session-transcript-resolver.test.ts` tests | 12 passed / 12 (baseline 12) | PASS |
| Test call sites (`it(` and `it.each`), base vs head | 9 vs 9; 6 vs 6 | PASS |
| `expect(` call sites, base vs head | 9 vs 9; 8 vs 8 | PASS |
| Full suite | 270 suites, 4002 tests passed | PASS |

## 7. Code Quality Checks

| Check | Result | Status |
|---|---|---|
| Prettier check (2 files) | exit 0 | PASS |
| ESLint (2 files) | exit 0, 0 problems | PASS |
| `tsc -p ./ --noEmit` | exit 0 | PASS |
| `tsc -p tsconfig.jest.json --noEmit` | exit 0 | PASS |
| AC-1 search token (case-insensitive), `workspace-encoding.test.ts` | 0 (baseline 33), reviewer `grep -ci` | PASS |
| Drive-letter path literal (`[A-Za-z]:[\\/]`), both files | 0 matches, reviewer `grep` | PASS |
| Encoded drive name literal (`[A-Za-z]--`), both files | 0 matches, reviewer `grep` | PASS |
| File length | 198 and 152 lines | PASS |
| Suppressions | 0 | PASS |
| Policy documents modified | 0 | PASS |
| Absolute host paths or encoded host names in committed artifacts (feature folder) | 0 | PASS |

## 8. Gaps and Exceptions

### Identified Gaps

No blocking gap remains. The following non-blocking observations are recorded.

#### R1 — Research artifact retains the mixed-case host user token as bare prose (Non-blocking)

- File: `research/2026-10-15T17-50-workspace-encoding-host-paths-research.md`, lines 31 and 56.
- Observation: line 31 names the two letter-case forms of the AC-1 search token, and line 56 quotes the `package.json` `publisher` identifier. Neither line holds a path or an encoded directory name. The caller's verification target permitted only the lowercase AC-1 token; these two lines carry the mixed-case form, so they fall outside that exception.
- Assessment: not blocking. The 01-25 remediation inputs (B1 expected end state) stated that prose naming the bare token without a path may remain; the cycle recorded the retention as decision D2; the string equals the public marketplace publisher identifier already committed in the extension manifest, so no additional host data is disclosed; and the governing rule addresses absolute host paths.
- Optional action: replace the mixed-case token on line 31 with `<host-user>` if the stricter reading is preferred.

#### R2 — Research derivation table predates the N1 signature change (Non-blocking)

The "New" column (research lines 107-120) shows `encodedNameOf(UPPER_DRIVE, ...)`, and line 145 refers to `${drive}--`; after N1 the helper takes only segments. The research file is a point-in-time artifact, and the plan and evidence document the change. No action required.

#### R3 — Coverage evidence remains a text log in untracked `SCRATCH/` (Non-blocking, carried from N3)

The canonical `coverage/lcov.info` is not present in the worktree; the coverage runs used the text reporter with output under `SCRATCH/issue-934/`. The reviewer verified the numbers from the raw logs, and the committed evidence records them numerically. No production file changed.

#### R4 — QA evidence predates the merge commit (Non-blocking, informational)

The cycle QA evidence was recorded at `c71a1d242`. The merge at `735a60d82` changed `.github/dependabot.yml`, `tests/scripts/dev_tools/test_dependabot_config_contract.py`, and issue #940 documents only; reviewer `git diff --stat c71a1d242 735a60d82` restricted to `extensions/drm-copilot/src/lib/subagent-tree`, `extensions/drm-copilot/test/lib/subagent-tree`, and this feature folder is empty. The Python file arrives from `main` and is not part of the branch diff against `origin/main`. CI on the PR head is the authoritative post-merge confirmation.

#### R5 — Parallel fixture constants and `test/` directory name (Non-blocking, carried from N2 and N4)

Unchanged by decision D6; both remain acceptable.

### Approved Exceptions

None.

### Removed/Skipped Tests

None. Test counts and titles are identical to baseline.

## 9. Summary of Changes

### Commits in This PR/Branch

- `bce207a57` docs(934): create minor-audit feature folder for workspace-encoding test host paths
- `e5565a7e3` docs(934): add research and minor-audit acceptance criteria
- `12fe84f32` docs(934): add minimal-audit plan for workspace-encoding test host paths
- `2c660e9d2` docs(934): apply preflight round 1 plan revisions
- `2eb4c6d79` test(#934): phase 0 baseline evidence for workspace-encoding host paths
- `67d370601` test(#934): compose workspace fixture paths at runtime without host paths
- `9fcf0909e` test(#934): phase 2 QA evidence and AC check-off
- `3fc0e86c8` docs(#934): feature review artifacts and remediation inputs
- `954423bab` docs(#934): remediation cycle 1 plan cleared preflight
- `3cd9d5a10` docs(#934): remediation cycle 1 phase 0 baseline
- `006ff12da` test(#934): drop single-valued drive parameter from encodedNameOf
- `c71a1d242` docs(#934): remediation cycle 1 redaction, status fix and QA evidence
- `735a60d82` Merge origin/main into bug/workspace-encoding-test-host-specific-paths-934

### Files Modified

- `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts`
- `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts`
- 83 Markdown files under `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/` (issue, plan, remediation plan, research, prior review artifacts, and evidence)

## 10. Compliance Verdict

### Overall Status: PASS — 0 blocking findings

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS.

#### Language-Specific Code Change Policy (Section 3)

TypeScript: PASS.

#### General Unit Test Policy (Section 1)

PASS.

#### Language-Specific Unit Test Policy (Section 4)

TypeScript: PASS.

### Metrics Summary

- Blocking findings: 0
- Non-blocking observations: 5 (R1-R5)
- TypeScript coverage: 97.26% lines / 92.28% branch, unchanged

### Recommendation

Proceed to PR authoring. R1 is optional.

## Appendix A: Test Inventory

`workspace-encoding.test.ts` (9, titles unchanged from baseline):

1. encodeWorkspacePath replaces backslashes, forward slashes, and colons with hyphens
2. encodeWorkspacePath encodes a forward-slash workspace path identically to a backslash one
3. matchEncodedDirectories matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name
4. matchEncodedDirectories includes a per-worktree sibling folder among the matched candidate directories
5. matchEncodedDirectories includes a nested worktree-of-a-worktree sibling folder
6. matchEncodedDirectories returns an empty array when no directory name matches
7. matchEncodedDirectories matches a new-scheme nested worktree sibling encoded name
8. matchEncodedDirectories matches a new-scheme worktree-of-a-worktree encoded name
9. matchEncodedDirectories matches by exact equality when the workspace root is the nested leaf

`session-transcript-resolver.test.ts` (12, unchanged in this cycle): seven `it.each` cases rejecting malformed session ids, and five resolution tests (exact-match directory, `-wt-` sibling, case-insensitive match, deterministic first match, not-found error).

## Appendix B: Toolchain Commands Reference

Run from `extensions/drm-copilot` unless noted:

- `npx prettier --check test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`
- `npx eslint test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`
- `npx tsc -p ./ --noEmit` and `npx tsc -p tsconfig.jest.json --noEmit`
- `npx jest --config jest.config.cjs --coverage`
- Worktree root: `git diff origin/main --name-only -- extensions/drm-copilot/src`
- Worktree root: `python scripts/dev_tools/validate_evidence_locations.py --root .`
