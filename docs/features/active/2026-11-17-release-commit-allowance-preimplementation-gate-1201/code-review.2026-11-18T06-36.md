# Code Review: Release-commit allowance leg of the preimplementation gates (#1201), post-merge re-audit

---

**Review Date:** 2026-11-18
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-17-release-commit-allowance-preimplementation-gate-1201`
**Feature Folder Selection Rule:** named by the caller; the folder's `issue.md` and `spec.md` carry issue #1201.
**Base Branch:** `main` (merge base `97044e5a1aea8a009fee42dad84760946c1a75cb`, equal to `origin/main` after a fetch)
**Head Branch:** `bug/release-commit-allowance-gate` at `03174b419f79a68bddc359382b6933532eb8af74`
**Review Type:** Re-audit after a merge of `origin/main` (concurrent with CI on PR #1202). Previous review: 2026-11-18T03-46 at `4140c7bb5`.

---

## Executive Summary

The merge brought `main`'s PR #1205 (issue #1204: `scripts/ci/NpmAuditGate.psm1`, `scripts/ci/Invoke-NpmAuditGate.ps1`, `config/npm-audit-exceptions.json`, `.github/workflows/_npm-audit-gate.yml`, three Pester suites, ledger entry 0013, and its feature folder).

**What the reviewer verified:**
- The branch diff from the new merge base, with the feature folder excluded, is byte-identical to the 03-46 diff (`cmp` of both `git diff` outputs without `index` lines). Every non-feature-folder path has the same blob at `4140c7bb5` and `03174b419`. The only new paths in the diff are the five 03-46 review files.
- The merge is clean. `git diff-tree --cc` prints no hunk, and `git merge-tree --write-tree` of the two parents reproduces the head tree `f011f3def`. The 44 paths `main` changed do not intersect the 115 paths of the branch diff.
- No semantic interaction. None of the branch's suites or the Jest exclusion test reads `scripts/ci/**`, the exception file, the audit workflow, or the process-reduction ledger. Main's change adds no hook, skill, rule, pack-manifest entry, or push-down resource. The execution-environment brief has blob `df1ed1264af6` in all six copies. The full Pester gate at the merged head ran 28216 tests with 0 failures.
- CI-2 is addressed on `main`. The exception covers GHSA-fc5q-39xc-vjpf (dev scope, expires 2026-12-18) and is consumed by the shared audit workflow. The branch does not touch the gate.

**Carried forward from 03-46 without re-review (content unchanged):** the cycle-0 production review (PASS), the cycle-1 module-binding fix, the AC-7 recorded deviation, and the Minor AD-5 `-C` case-insensitivity note.

**Top 3 risks:**
1. CI at head `03174b419` is still running, so AC-31 stays open until the orchestrator join.
2. The advisory exception expires 2026-12-18; after that the audit gate fails again on `main` and on any branch unless picomatch is patched or the exception is renewed. This is a `main`-side concern (issue #1204), not a finding for this branch.
3. Carried forward: no static guard covers module-table replacement leaks.

**PR readiness recommendation:** **Go once CI is green at head `03174b419`.** No finding blocks.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | CI: `NPM Audit Gate / npm audit (.)` and `(extensions/drm-copilot)` | PR #1202 at `03174b419` | Finding CI-2 from 03-46 is addressed by the exception now on `main`. During the review the `extensions/drm-copilot` and `packages/mcp-server` jobs had passed and `npm audit (.)` was pending. | The orchestrator confirms both jobs and `CI Required Gate` at the join. | The branch changes no manifest, lockfile, audit workflow, or exception. | `config/npm-audit-exceptions.json`; `_npm-audit-gate.yml` line 55; PR #1205 npm-audit jobs pass; `gh pr checks 1202`. |
| Minor | `tests/scripts/claude-hooks/*` (18 suites) | file-level or Describe-level `AfterAll` | Carried forward from 03-46: the leaker teardowns contradict the literal text of AC-7 ("no diff to any pre-existing test file"). | Record the deviation in the PR description; no code change. | Spec wording predates the discovered leak; repository test-isolation policy governs the fix. | 03-46 code review and feature audit; files unchanged. |
| Minor | `.claude/hooks/hook-release-allowance-context.ps1` and copies | `-C` root comparison | Carried forward from cycle 0: the `-C` root comparison is case-insensitive by spec AD-5. | Revisit in the epic #1018 adaptation. | Spec-sanctioned; deferred. | Cycle-0 review; files unchanged. |
| Info | `artifacts/pester/powershell-coverage.xml` | n/a | The 03-46 report predated the merge commit, which brings PowerShell files from `main`, so the reviewer re-ran the PowerShell gate once (28216 tests, 0 failures, 45487/47337 lines). Branch-file figures are identical to 03-46. | None. | Coverage freshness is keyed to the newest commit touching `*.ps1`/`*.psm1`. | `evidence/qa-gates/review-pester.2026-11-18T06-36.md`. |

No covered file reaches 700 logical lines (every branch file's blob is unchanged since 03-46, where the largest was 539), so there is no file-size Warning row. `config/file-size-baseline.json` is unchanged by the branch.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- Unchanged since cycle 0 (one `EXCLUDED_RELATIVE_PATHS` entry).

#### Typing and API notes

- No new public Python API surface; no new Python module or test (AC-32).

#### Error handling and logging

- No new control flow.

### TypeScript implementation audit

#### What changed well

- Unchanged since cycle 0 (one `EXCLUDED_RELATIVE_PATHS` entry with a three-test Jest contract).

#### Type safety and maintainability

- No suppression; unchanged.

#### Error handling and logging

- No new behavior.

### PowerShell implementation audit

#### What changed well

- Unchanged since 03-46. The merged `main` files (`NpmAuditGate.psm1`, `Invoke-NpmAuditGate.ps1`) are outside the branch's paths and were reviewed under issue #1204. They pass in the reviewer gate run (161/161 and 50/55 lines).

#### API and safety notes

- Four-copy hook hashes unchanged (same blobs as `4140c7bb5`).

#### Error handling and logging

- Unchanged.

---

## Test Quality Audit

No test changed since 03-46. The merged head passes the full Pester gate (28216 tests, 0 failures, 0 errors), which includes the branch's 600 new tests, the 18 teardown-edited suites, and `main`'s three new suites in the same parallel run.

### Reviewed test and QA artifacts

- `evidence/qa-gates/review-pester.2026-11-18T06-36.md` — reviewer gate run at the merged head.
- 03-46 review artifacts — carried forward for unchanged content.

### Quality assessment prompts

- **Determinism:** unchanged.
- **Isolation:** unchanged; the merged suites do not load the branch's hooks.
- **Speed:** 765.09 s wall-clock (755.55 s at 03-46).
- **Diagnostics:** unchanged.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Branch content unchanged; the merge adds no branch-side file. |
| No unsafe subprocess or command construction | ✅ PASS | Unchanged. |
| Input validation at boundaries | ✅ PASS | Unchanged. |
| Error handling remains explicit | ✅ PASS | Unchanged. |
| Configuration / path handling is safe | ⚠️ PARTIAL | Carried forward: case-insensitive `-C` root comparison by spec AD-5 (Minor, deferred to epic #1018). |

---

## Research Log

No external research was required. The exception file and audit workflow were read from the merged head, and PR #1205 check results were read with `gh pr checks`.

---

## Verdict

The merge is clean and does not alter the branch's reviewed content. The 03-46 judgments stand, and the only previous blocker (CI-2) is addressed by the exception on `main`. No finding blocks. Merge readiness depends on green CI at head `03174b419`, which the orchestrator confirms at the join.
