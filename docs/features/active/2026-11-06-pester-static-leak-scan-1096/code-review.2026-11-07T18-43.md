# Code Review: pester-static-leak-scan (#1096)

---

**Review Date:** 2026-11-07
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-06-pester-static-leak-scan-1096`
**Feature Folder Selection Rule:** Supplied by the caller; its suffix matches the issue number in the branch name.
**Base Branch:** `main` (merge base `c24cbd295ecec1fc759f52a42806ad991aa49478`, equal to `origin/main`)
**Head Branch:** `feature/pester-static-leak-scan-1096` (`cb8ae3d5cc496bb1e0877aba0ae87661df00d066`)
**Review Type:** Re-audit after remediation cycle 2

---

## Executive Summary

The review scope is the full branch diff against the merge base. The feature content (two PoshQC sub-modules for the static Pester leak scan, the allowlist, CI step, VS Code task, `fix_all` step, leak fixes, parallel-gate command edits, brief edits, and ledger entry 0001) was reviewed in `code-review.2026-11-07T16-00.md` and `code-review.2026-11-07T17-25.md`. This re-audit re-checked it at head and reviewed the cycle 2 changes.

Cycle 2 consisted of two merges of `origin/main` and evidence commits. Comparing blob ids between the cycle 1 head `36372b6c6` and the current head, the only branch-diff paths that changed are the six `execution-environment` brief copies and `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, all through the merges. No production module, test suite of the scan, configuration, or workflow file changed in the cycle.

- Merge `eca1041af` (PR #1110): one conflicted hunk, step 1 of `## Revert Steps` in entry 0001. The resolution keeps main's instruction to revert entry `0006` first and appends the branch's sentence on the #1096 blocks. Main's `## Partial Revert` section is present. The brief auto-merged, and the test file gained main's `Phase 0 baseline` token next to the branch's scan assertions.
- Merge `885c52b2f` (PR #1113): conflict-free; within the branch diff it changed only `## Hook Execution Context` of the brief.

Verification by this review: static tools clean over 18 Python and 22 PowerShell changed files; leak scan 0 failures over 568 files; 177 of 177 ledger fences replay across entries 0001 to 0006; coverage artifacts parsed and matching the restart gate records; six brief copies with one blob id; CI run `42400459749` on `885c52b2f` green with the scan step passing.

No blocking finding remains.

**Top 3 risks:**
1. The scan is file-local and static; a leak through a helper in another file or through production code is not detected, as the spec records.
2. `test_prompt_builder.py` is at 769 logical lines (768 on `main` before this branch); the next additions there will approach the 800-line hard limit.
3. The change-scope job skips `poshqc / PowerShell QC static` for a head whose later commits touch only the feature folder, so the scan step does not run on the final head; criterion 36 rests on the run at `885c52b2f`.

**PR readiness recommendation:** **Ready** — no code change is required; the S9 CI green gate confirms the final head.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Warning | `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py` | whole file | 769 logical lines, at or above the 700-line advisory tier. The file had 768 lines at the merge base; this branch adds one assertion. | Split by a logical seam in a later change to that file. | `.claude/rules/general-code-change.md` `## File Size Limit` advisory tier. Non-blocking; the tier was crossed on `main`. | Logical line count by `awk 'END{print NR}'` at head and at `c24cbd295`. |
| Info | `scripts/powershell/PoshQC/PoshQC.LeakScan.psm1` | `Get-PoshQCLeakPairing`, rule R3 | A restore inside a nested block of the same statement list does not pair under R3 and is itself reported. | None required; the spec defines R3 as the same block, and such a case goes to the allowlist with a reason. | Conservative behavior, carried from the first review. | Reviewer probe P22 of the first review. |
| Info | `docs/engineering/process-reductions/0001-parallel-only-test-gates.md` | `## Revert Steps` step 1 | MC-2 closed. The conflicted hunk keeps both sides: main's `0006`-first ordering and patch handling, then the branch's sentence that the #1096 blocks apply whether or not the patch check passes. One `Merge commit:` line; no `Before #1096 lands`. | None. | `merge-conflicts.2026-11-07T17-44.md` records stage 2, stage 3, and the resolution. | Reviewer read of the entry; replay of 177 blocks, 0 failed; `Test-ProcessReductionLedger` valid. |
| Info | `.claude/skills/execution-environment/SKILL.md` and five copies | `## Test Isolation Checks`, `## Hook Execution Context` | MC-2 brief guarantee holds. One blob id `452229bc0` across the six copies; the scan bullet is the last bullet of `## Test Isolation Checks`. | None. | `test_brief_copies_are_byte_identical` and `PGW-SWEEP-SURFACES` passed in the restart gates. | `git rev-parse HEAD:<path>` for each copy. |
| Info | `.github/workflows/_poshqc.yml` | job `poshqc-static`, step `Scan Pester tests for leaked state` | PA-1 of the cycle 1 re-audit closed. CI run `42400459749` on `885c52b2f` succeeded, the step logged `Leak scan: 568 files, 69 findings, 67 exempt, 2 allowlisted, 0 failures.`, and `CI Required Gate` succeeded. | None. | Predecessor-head conditions of `modified-workflow-needs-green-run` hold; no later commit changes a path outside the feature folder. | `gh run view 42400459749 --json jobs`; job `128487118140` log. |
| Info | branch | merges with `origin/main` | Both cycle 2 merge commits have two parents and carry no reduction token; `origin/main` is an ancestor of head after `git fetch origin`. | None. | Plan rule against rebase and forced push held. | `git log --format='%h %P'`; `git merge-base --is-ancestor origin/main HEAD` exit 0. |

---

## Detailed Review

### Merge resolution (MC-2)

- Entry 0001, `## Revert Steps` step 1: reads main's text ("revert entry `0006` ... first ... Then run `git apply -R` of the patch when its check passes. Otherwise replace each `Current` with its `Prior` ...") followed by the branch's sentence on the #1096 blocks. Steps 5 and 6 carry main's text with the branch's #1096 additions appended.
- Entry 0001, `## Revert Signals`: one bullet names a leak that `Invoke-PoshQCLeakScan` misses.
- `test_execution_environment_brief_contracts.py`: main's change of `"no earlier figure is compared"` to `"Phase 0 baseline"` under `## Coverage and File-Size Gates` sits next to the branch's `Invoke-PoshQCLeakScan` entries; each `def test_` name occurs once.

### Leak scan on the merged tree

The file count rose from 558 (cycle 1) to 568 with the Pester suites that PR #1110 and PR #1113 added. Neither merge produced a new finding: 69 findings, 67 exempt through `LASTEXITCODE`, 2 allowlisted, and no stale entry.

### Typed-Python review

No Python production file changed in cycle 2. The one test-file change is a string literal from the auto-merge. Pyright reports 0 errors over the 18 changed files.

### Workflow

The `pwsh` step calls a PowerShell function and no native command, so no `$LASTEXITCODE` can leak (`.claude/rules/ci-workflows.md`). `WF06-LEAK-SCAN-STEP` pins the step order and the absence of `continue-on-error` and `if`. The `poshqc-linux-hooks` job text equals the merge base.

---

## Positive Observations

- The conflict record keeps both sides of the hunk, which made the resolution checkable line by line.
- The plan's ancestry rule caught the `origin/main` advance from PR #1113 and the cycle restarted its gates on the merged tree instead of reusing pre-merge figures.
- Gate evidence records the scan file count, which made the effect of the merged suites visible.
