# Policy Compliance Audit: Issue #934 — workspace-encoding test host-specific paths

- Issue: #934
- Branch: `bug/workspace-encoding-test-host-specific-paths-934`
- Head: `9fcf0909eb24a6c3a0cdb419149e2288baa7cc9f`
- Resolved base: `origin/main` at `adb9aa5f02fc0ae84fd7e6060f758a8b0974eb99` (merge base equals `origin/main`; the branch is current with base)
- Work mode: `minor-audit` (from `issue.md`)
- Review timestamp (UTC): 2026-10-16T01-25
- PR context: `artifacts/pr_context.summary.txt` records `Head SHA: 9fcf0909...` and `Merge base: adb9aa5f...`, matching the branch; the context is current and was not regenerated.

## Total Blocking Findings: 1

### Coverage Evidence Checklist

- TypeScript baseline coverage artifact: Jest text-reporter log `SCRATCH/issue-934/jest-coverage-baseline.log` (untracked; read by the reviewer), summarized in `evidence/baseline/jest-coverage.2026-10-16T00-20.md`
- TypeScript post-change coverage artifact: Jest text-reporter log `SCRATCH/issue-934/jest-coverage-final.log` (untracked; read by the reviewer), summarized in `evidence/qa-gates/jest-coverage.2026-10-16T01-16.md` and `evidence/qa-gates/coverage-delta.2026-10-16T01-17.md`
- PowerShell baseline coverage artifact: N/A - no PowerShell files changed on the branch
- PowerShell post-change coverage artifact: N/A - no PowerShell files changed on the branch
- Per-language comparison summary: section 1.2.1 of this document

## Executive Summary

The branch replaces literal host-specific absolute paths and encoded directory names in two Jest test files with values composed at runtime from a drive-letter token, `path.win32.sep` / `path.posix.sep`, and neutral segments (`fixtureuser`). No production file changes. Prettier, ESLint, both `tsc` configurations, the per-file Jest runs (9/9 and 12/12), and the full coverage run (270 suites, 4002 tests) pass according to the recorded evidence, and the reviewer's own checks confirm zero host-path or drive-letter literals in either test file, unchanged test and assertion counts, no suppressions, no temporary files, and both files under 500 lines.

One blocking finding exists: the committed research artifact reproduces the removed host-path literals verbatim (B1), which conflicts with the repository rule the issue itself cites. It is autonomously remediable by redacting six lines. Five non-blocking findings are recorded.

## Rejected Scope Narrowing

No scope narrowing was attempted by the caller. The caller prompt asked for review of the two test files plus feature-folder documents and evidence, which matches the full branch diff (`git diff --name-only origin/main...HEAD`, 41 paths). No exclusion of any language or toolchain stage was requested.

## Evidence Location Compliance

- `python scripts/dev_tools/validate_evidence_locations.py --root <worktree>`: exit 0, no output.
- Branch-diff scan for paths under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`: zero matches.
- All 35 evidence files are under `<FEATURE>/evidence/baseline/`, `<FEATURE>/evidence/qa-gates/`, or `<FEATURE>/evidence/other/`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` event occurred in this review.

Verdict: PASS.

## 1. General Unit Test Policy Compliance

### 1.1 Core Principles

- Independence and isolation: each test builds its own inputs from module-level immutable constants and pure helper functions; no shared mutable state. PASS.
- Fast execution and determinism: no clock, RNG, timer, network, or filesystem use was added. The only new import is `node:path`, used for its `sep` constants. PASS.
- Readability: helper names (`workspacePathOf`, `encodedNameOf`) and JSDoc or line comments state the purpose of each constant. PASS.

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

- TypeScript: Baseline: 97.26% lines / 92.28% branch -> Post-change: 97.26% lines / 92.28% branch. Change: none (0.00 points). Exercised modules: `src/lib/subagent-tree/workspace-encoding.ts` 100% lines / 100% branch before and after; `src/lib/subagent-tree/session-transcript-resolver.ts` 100% lines / 85.71% branch before and after. No production line changed, so changed-line coverage has no denominator. Disposition: PASS. Evidence: `SCRATCH/issue-934/jest-coverage-baseline.log`, `SCRATCH/issue-934/jest-coverage-final.log`, `evidence/baseline/jest-coverage.2026-10-16T00-20.md`, `evidence/qa-gates/jest-coverage.2026-10-16T01-16.md`, `evidence/qa-gates/coverage-delta.2026-10-16T01-17.md`.
- Python: N/A - no changed files on the branch.
- PowerShell: N/A - no changed files on the branch.
- C#: N/A - no changed files on the branch.

The reviewer extracted the `All files`, `workspace-encoding.ts`, and `session-transcript-resolver.ts` rows from both raw logs with `grep`; the values match the committed evidence. The final log reports `Test Suites: 270 passed, 270 total` and `Tests: 4002 passed, 4002 total`, with no line containing `threshold`. `jest.config.cjs` is not modified on this branch, so no coverage `exclude` entry was added.

### 1.3 Test Structure and Diagnostics

Every test keeps the `// Arrange`, `// Act`, `// Assert` comment structure from the baseline. Assertions use `toBe` / `toEqual` with composed expected values; Jest prints both sides on failure. PASS.

### 1.4 External Dependencies and Environment

`grep -nE 'tmpdir|mkdtemp|writeFileSync|fs\.|os\.'` returned no match in either file. The session-transcript tests continue to use the existing `InMemoryFileSystem` fake. The change removes the dependency of fixture values on one host's directory layout. PASS.

### 1.5 Policy Audit Requirement

This document is the policy audit for the branch. PASS.

## 2. General Code Change Policy Compliance

### 2.1 Before Making Changes

`evidence/baseline/phase0-instructions-read.2026-10-16T00-08.md` records the policy reading order; baseline evidence for tests, coverage, line counts, and host-path counts was captured before the change. PASS.

### 2.2 Design Principles

The helpers are two small pure functions in `workspace-encoding.test.ts` and three constants in `session-transcript-resolver.test.ts`. Simplicity is preserved. N1 and N2 record minor non-blocking observations. PASS.

### 2.3 Module & File Structure

`wc -l` at head: `workspace-encoding.test.ts` 219 lines, `session-transcript-resolver.test.ts` 152 lines; both are under the 500-line limit. Production files changed: 0 (`git diff --name-only origin/main...HEAD -- extensions/drm-copilot/src` returned no output). PASS.

### 2.4 Naming, Docs, and Comments

Constants use `UPPER_SNAKE_CASE`, helpers use `camelCase`. The rewritten comment in the new-scheme test replaces the absolute path with `<workspace parent>/drm-copilot-wt/<timestamp>`. PASS.

### 2.5 After Making Changes - Toolchain Execution

The seven-stage loop was recorded as completing in a single pass (`evidence/qa-gates/end-state-summary.2026-10-16T01-19.md`). Stages 4 (architecture), 6 (contract), and 7 (integration) have no input in a test-only change. PASS.

### 2.6 Summarize and Document

Plan, research, and evidence artifacts exist in the feature folder. The research artifact contains host paths (B1). PARTIAL.

## 3. Language-Specific Code Change Policy Compliance

### Section 3A: TypeScript Code Change Policy Compliance

#### 3A.1 Tooling & Baseline

Prettier, ESLint, and `tsc` were run at baseline (`evidence/baseline/prettier-check.2026-10-16T00-15.md`, `eslint.2026-10-16T00-15.md`, `tsc-src.2026-10-16T00-15.md`, `tsc-jest.2026-10-16T00-15.md`). PASS.

#### 3A.2 Types and Safety

Helpers have explicit parameter and return types. `grep -nE 'eslint-disable|ts-ignore|ts-expect-error|ts-nocheck|as any|: any'` returned no match in either file. `extensions/drm-copilot` is tier T3 in `quality-tiers.yml`; zero escape hatches satisfies the T3 limit. PASS.

#### 3A.3 Structure, Naming, and Comments

Imports use `node:path`, matching the extension's existing Node built-in import style. PASS.

#### 3A.4 Running the Toolchain

Post-change Prettier check, ESLint, `tsc -p ./ --noEmit`, and `tsc -p tsconfig.jest.json --noEmit` all exit 0 with empty output (`evidence/qa-gates/*.2026-10-16T01-13.md`). The reviewer did not rerun these commands. PASS.

## 4. Language-Specific Unit Test Policy Compliance

### Section 4A: TypeScript Unit Test Policy Compliance

#### 4A.1 Framework and Scope

Jest with `@jest/globals` imports, unchanged from baseline. PASS.

#### 4A.2 Test Style and Structure

Arrange–Act–Assert preserved in all 21 tests. PASS.

#### 4A.3 Naming and Readability

All test titles are unchanged; `evidence/qa-gates/jest-workspace-encoding.2026-10-16T01-14.md` and `jest-session-transcript-resolver.2026-10-16T01-15.md` record title lists identical to baseline. PASS.

#### 4A.4 Running the Toolchain

`npx jest --runTestsByPath` for each file: 9/9 and 12/12 passed. Full coverage run: 270/270 suites, 4002/4002 tests. PASS.

## 5. Test Coverage Detail

### src/lib/subagent-tree/workspace-encoding.ts (exercised by 9 tests) — 100% lines, 100% branch

Unchanged from baseline. Production file not modified.

### src/lib/subagent-tree/session-transcript-resolver.ts (exercised by 12 tests) — 100% lines, 85.71% branch

Unchanged from baseline; the uncovered branch at line 71 is pre-existing and was not introduced by this branch. Production file not modified.

## 6. Test Execution Metrics

| Metric | Value | Status |
|---|---|---|
| `workspace-encoding.test.ts` tests | 9 passed / 9 (baseline 9) | PASS |
| `session-transcript-resolver.test.ts` tests | 12 passed / 12 (baseline 12) | PASS |
| `it(` call sites, base vs head | 9 vs 9; 5 vs 5 (plus one 7-case `it.each`) | PASS |
| `expect(` call sites, base vs head | 9 vs 9; 8 vs 8 | PASS |
| Full suite | 270 suites, 4002 tests passed | PASS |

## 7. Code Quality Checks

| Check | Result | Status |
|---|---|---|
| Prettier check (2 files) | exit 0 | PASS |
| ESLint (2 files) | exit 0, 0 problems | PASS |
| `tsc -p ./ --noEmit` | exit 0 | PASS |
| `tsc -p tsconfig.jest.json --noEmit` | exit 0 | PASS |
| `danmoisan` token (case-insensitive), `workspace-encoding.test.ts` | 0 (baseline 33), reviewer `grep -ci` | PASS |
| Drive-letter path literal (`\b[A-Za-z]:[\\/]`), both files | 0 matches, reviewer `grep` | PASS |
| Encoded drive name literal (`[A-Za-z]--` at a token boundary), both files | 0 matches, reviewer `grep` | PASS |
| File length | 219 and 152 lines | PASS |
| Suppressions | 0 | PASS |
| Policy documents modified | 0 | PASS |
| Absolute host paths in committed artifacts (feature folder) | 6 lines in the research artifact | FAIL (B1) |

## 8. Gaps and Exceptions

### Identified Gaps

#### B1 — Research artifact re-introduces the removed host paths (Blocking)

- Severity: Blocking
- File: `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/research/2026-10-15T17-50-workspace-encoding-host-paths-research.md`, lines 55 and 107–111.
- Observation: the derivation table and the related-occurrence note quote the old drive-letter absolute paths containing the host user segment and their encoded directory names. The branch removes these literals from the test files and adds them to a committed artifact in the same change.
- Rule: `issue.md` §Suspected Cause cites the repository rule "never encode absolute host paths in artifacts", which is the defect this issue fixes.
- Remediation: replace the quoted literals with placeholder forms (for example `<drive>:\\Users\\<host-user>\\repos\\drm-copilot` and `<drive>--Users-<host-user>-repos-drm-copilot`), keeping the line-number references and the new-expression column. Re-run `grep -nE '[A-Za-z]:[\\/]{1,2}Users[\\/]{1,2}[A-Za-z]'` and a case-insensitive search for the host user segment followed by a path separator or hyphen on the feature folder to confirm zero path matches.
- Remediability: autonomous

#### N1 — `encodedNameOf` drive parameter has a single value (Non-blocking)

Every call site passes `UPPER_DRIVE`; the lowercase case is produced by `.toLowerCase()` on the whole name. The parameter is unused flexibility. Optional simplification.

#### N2 — Parallel fixture helpers in two files (Non-blocking)

The two test files compose fixtures with separate constants (`PARENT_SEGMENTS` + `REPO` versus `WORKSPACE_SEGMENTS`). The duplication is small and limited to two files; a shared fixture module is not required.

#### N3 — Coverage evidence is a text log in an untracked scratch folder (Non-blocking)

The coverage runs used `--coverageReporters=text` with output under `SCRATCH/issue-934/`, so the canonical `coverage/lcov.info` is not present in the worktree. The reviewer verified the numbers directly from the raw logs, and the committed evidence records them numerically. Because no production file changed, this does not affect the verdict.

#### N4 — Test directory is `test/` rather than `tests/` (Non-blocking, pre-existing)

`extensions/drm-copilot` uses `test/` mirroring `src/`. Both files pre-exist at these paths and were not moved; no test file was placed in `src/`.

#### N5 — `issue.md` Status line names a different folder (Non-blocking)

`issue.md` line 5 reads `Promoted -> docs/features/active/workspace-encoding-test-host-specific-paths/`; the actual folder is `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/`. Documentation drift only.

### Approved Exceptions

None.

### Removed/Skipped Tests

None. Test counts and titles are identical to baseline.

## 9. Summary of Changes

### Commits in This PR/Branch

- `12fe84f32` docs(934): add minimal-audit plan for workspace-encoding test host paths
- `2c660e9d2` docs(934): apply preflight round 1 plan revisions
- `2eb4c6d79` test(#934): phase 0 baseline evidence for workspace-encoding host paths
- `67d370601` test(#934): compose workspace fixture paths at runtime without host paths
- `9fcf0909e` test(#934): phase 2 QA evidence and AC check-off

### Files Modified

- `extensions/drm-copilot/test/lib/subagent-tree/workspace-encoding.test.ts` (+74/-47)
- `extensions/drm-copilot/test/lib/subagent-tree/session-transcript-resolver.test.ts` (+11/-6)
- 39 Markdown files under `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/` (issue, plan, research, 35 evidence files)

## 10. Compliance Verdict

### Overall Status: PARTIAL — 1 blocking finding

### Policy-by-Policy Summary

#### General Code Change Policy (Section 2)

PASS for design, file size, naming, and toolchain; PARTIAL for documentation because of B1.

#### Language-Specific Code Change Policy (Section 3)

TypeScript: PASS.

#### General Unit Test Policy (Section 1)

PASS.

#### Language-Specific Unit Test Policy (Section 4)

TypeScript: PASS.

### Metrics Summary

- Blocking findings: 1 (B1, autonomous)
- Non-blocking findings: 5 (N1–N5)
- TypeScript coverage: 97.26% lines / 92.28% branch, unchanged

### Recommendation

Redact the host-path literals in the research artifact (B1), then re-run the feature-folder search. No code change is required.

## Appendix A: Test Inventory

`workspace-encoding.test.ts` (9):

1. encodeWorkspacePath replaces backslashes, forward slashes, and colons with hyphens
2. encodeWorkspacePath encodes a forward-slash workspace path identically to a backslash one
3. matchEncodedDirectories matches an on-disk directory whose drive-letter segment uses a lowercase letter against an uppercase-encoded workspace name
4. matchEncodedDirectories includes a per-worktree sibling folder among the matched candidate directories
5. matchEncodedDirectories includes a nested worktree-of-a-worktree sibling folder
6. matchEncodedDirectories returns an empty array when no directory name matches
7. matchEncodedDirectories matches a new-scheme nested worktree sibling encoded name
8. matchEncodedDirectories matches a new-scheme worktree-of-a-worktree encoded name
9. matchEncodedDirectories matches by exact equality when the workspace root is the nested leaf

`session-transcript-resolver.test.ts` (12): seven `it.each` cases rejecting malformed session ids, and five resolution tests (exact-match directory, `-wt-` sibling, case-insensitive match, deterministic first match, not-found error).

## Appendix B: Toolchain Commands Reference

Run from `extensions/drm-copilot` unless noted:

- `npx prettier --check test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`
- `npx eslint test/lib/subagent-tree/workspace-encoding.test.ts test/lib/subagent-tree/session-transcript-resolver.test.ts`
- `npx tsc -p ./ --noEmit` and `npx tsc -p tsconfig.jest.json --noEmit`
- `npx jest --config jest.config.cjs --runTestsByPath test/lib/subagent-tree/workspace-encoding.test.ts`
- `npx jest --config jest.config.cjs --coverage`
- Worktree root: `git diff --name-only origin/main...HEAD -- extensions/drm-copilot/src`
- Worktree root: `python scripts/dev_tools/validate_evidence_locations.py --root .`
