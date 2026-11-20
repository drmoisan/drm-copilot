# Feature Audit: test launcher drops positional Jest path (#1192)

---

**Audit Date:** 2026-11-15
**Feature Folder:** `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192`
**Base Branch:** `main`
**Head Branch:** `bug/test-launcher-jest-positional-path`
**Work Mode:** `full-bug`
**Audit Type:** Full audit of the branch diff against the merge base

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main`, merge base `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb`)
- **Head branch/commit:** `bug/test-launcher-jest-positional-path` (commit `3c42b7be6803f2afbf69c210f352ebf8473e5d93`)
- **Merge base:** `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb`
- **Evidence sources:**
  - Primary: the full branch diff and the PR context artifacts.
  - Feature evidence: baseline Pester gate, fail-before record, phase gates, final Pester gate, final contracts, final static record, and scope check under `evidence/`.
  - Re-verified in this review: the builder diff; blob-hash equality of the four hook copies; the test diffs; the `jest.docs-coverage.json` entry count (seven); the diff file list against the AC-9 collateral-change list; zero Python paths in the diff.
- **Feature folder used:** `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-bug`, so `spec.md` `## Acceptance Criteria` is the only AC source.
- **Scope note:** PR #1194 is open; CI jobs on the head were partly pending at review time.

---

## Acceptance Criteria Inventory

**Authoritative AC source file for this run:**
- `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192/spec.md` - 10 checkbox items under `## Acceptance Criteria` (10 checked at review start)

Numbering AC-1 to AC-10 follows the file.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-1 | Jest single positional precedes the first `--testPathIgnorePatterns` word; every exclusion word present | PASS | Updated case asserts `node run-jest.cjs tests/unit/a.test.ts --testPathIgnorePatterns=/node_modules/`, 10 ignore words, count 13; new case asserts index 2 versus 3. | `git diff` of the hook test file | Already checked. |
| AC-2 | Pester `-TestPath <path>` extra precedes `-ExcludeTag` and `-ExcludeTestFileSuffix`, exclusions intact | PASS | New case asserts words 0 to 6 hold the extra, word 7 is `-ExcludeTag`, then the suffix group verbatim. | Test diff | Already checked. |
| AC-3 | No extras leaves jest and pester commands equal to the pre-change commands | PASS | New `-ForEach` case asserts the full expected word string for both suites; it passed against the unmodified builder (fail-before record). | Test diff; fail-before record | Already checked. |
| AC-4 | Lane and worker rules unchanged; launcher test asserts refusal beside a valid positional | PASS | Launcher case asserts exit 0 with one start for a valid positional and exit 2 with `TEST_EXECUTION_POLICY_BLOCKED:*` and zero starts for an integration operand; the diff leaves refusal, worker-reduction, and lock code untouched. | Test diff; hook diff | Already checked. |
| AC-5 | pytest, dotnet-test, bats keep suite words, exclusions, extras | PASS | `-ForEach` case with head and last-word assertions for the three runners. | Test diff | Already checked. |
| AC-6 | Four hook copies byte-identical; resource and pack-manifest contract tests pass | PASS | Blob hash `fb929f590c2c7ec1eae9d254fbc7a1d532c60041` for all four copies at HEAD; 56 contract tests passed. | `git show HEAD:<path>` piped to `git hash-object --stdin`; `final-contracts.2026-11-15T20-05.md` | Already checked. |
| AC-7 | Existing Jest case updated, not weakened or removed, with a comment stating the reason | PASS | The case keeps its name and its exclusion-word count (10) and total (13) assertions, and gains the positional-precedes assertion and a comment on the array option. | Test diff | Already checked. |
| AC-8 | Stale `jest.config.cjs` comment matches `jest.docs-coverage.json` | PASS | Comment says seven; the JSON file lists seven modules. | Diff; JSON entry count | Already checked. |
| AC-9 | No collateral change: launcher shell, `Invoke-TestSuite.ps1`, `run-jest.cjs`, policy config, brief unchanged; no Python | PASS | The diff file list excludes every named file and the execution-environment brief copies; zero `.py` paths; scope-check record agrees. | `git diff --name-only`; `scope-check.2026-11-15T20-05.md` | Already checked. |
| AC-10 | Format, lint, and affected Pester suites pass in one parallel run; changed-line coverage meets the threshold | PASS | Static record EXIT_CODE 0 with zero findings; Pester gate 26870 tests, 0 failures; hook coverage 100% (173 of 173). | `final-static-powershell` and `final-pester-gate` records | Already checked. |

---

## Summary

All ten acceptance criteria are verified by the diff and the recorded gates. Pending CI jobs (PowerShell QC shards, Linux hook suites, Python quality, Windows extension tests) are awaiting CI; none of the ten criteria is defined by a CI result, so the verdict does not depend on them, but the PR should merge only after they report green.

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192/spec.md`
- Total AC items: 10
- Checked off (delivered): 10
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-11-15-test-launcher-drops-positional-jest-path-1192/spec.md` | 10 | 10 | 0 | none |

Newly checked off in this review: none. All ten were already checked at review start and each was re-verified against the diff and the recorded evidence.
