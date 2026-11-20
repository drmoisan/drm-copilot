# Code Review: Parallel Run Closing records PR blocked by the routing receipt (#1182), cycle 1 exit re-audit

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-parallel-close-records-pr-blocked-by-routing-receipt-1182`
**Feature Folder Selection Rule:** named by the caller; matches branch `bug/parallel-close-records-pr-routing-receipt` and issue #1182
**Base Branch:** `main` (resolved `origin/main` after `git fetch`; merge base `d7ef763637319b2aa2f886ecdab7a11be0044491`)
**Head Branch:** `bug/parallel-close-records-pr-routing-receipt` at `0f18cbd8e132e0a60d766f28632ca2b5f08528fc`
**Review Type:** Re-audit, remediation cycle 1 exit, concurrent mode (PR #1183 open; PR CI on the head completed green during the review)

---

## Executive Summary

The review covers the full branch diff from the merge base `d7ef76363` to the head `0f18cbd8e` (89 files). Since the prior review at `06cc8b03d`, the branch received one test commit (`825b8000c`), one fix commit (`bd1b2856d`), evidence and record commits, and a conflict-free merge of `origin/main` (`0f18cbd8e`).

Focus-area results:

1. CR-1 resolved. The AC-12 listing-throw row now asserts `Should -BeExactly` on the full text `PREIMPLEMENTATION_GATE_BLOCKED: TARGET_WORKTREE_NOT_DERIVABLE: ... resolver source SessionRoot: the worktree list failed: locked. ...`, in the style of its sibling rows, and keeps the leg-level `Allowed` false, empty-suffix, and `deny` assertions. The row passed in run 43615945680, so the literal matches what the gate produces.
2. CR-2 resolved. `Get-OrchestrationParallelRecordsRoot` returns `$null` when the normalized path fails `-cnotmatch '/artifacts/pr_body_[0-9]+\.receipt\.json$'`, placed after the relative-receipt return and the absolute-shape test and before `Get-OrchestrationCleanupListingRecord`; no resolver call precedes it. Row `(h)` asserts `Should -Invoke Get-OrchestrationGateWorktreeList -Times 0 -Exactly` and the unchanged gate text `$script:Blocked`. The fail-before record (`evidence/regression-testing/fail-before.2026-11-14T16-07.md`) shows this row failing with "called 1 time" before the fix, so it discriminates. The leg and its bundle copy share one SHA-256 value; the leg is 136 logical lines and its suite 297.
3. Main merge. The branch's per-path `--numstat` is identical across the old and new bases. Main's test-execution-policy hook is registered for the matcher of `Bash` and the two PoshQC MCP tools only, so it does not see the `Write` and `Agent(pr-author)` calls the legs admit; no function-name collision exists between main's five new hook files and the three new branch hook files; the six brief copies are byte-identical with the #1182 bullet present; the non-goal set is untouched.
4. Prior review still holds: narrow legs, unchanged deny text for non-matching inputs, test isolation, coverage (100% for each new file, edited hooks 96.36% and 96.53%), AC check-offs 24 of 25 with AC-25 left for the S9 check-off (PR CI green on the head).

**What changed in cycle 1:**
Three added lines in the preimplementation leg (one script-scope pattern, one early return) plus two header lines; one new test row and one tightened assertion; the same leg change in the bundle copy.

**Top 3 risks:**
1. The prefilter uses the cleanup normalizer, which neither trims whitespace nor collapses doubled slashes, while the later relative-path test uses the hook-target normalizer, which does both. A receipt path written with a doubled slash or surrounding whitespace now declines before the listing, where before cycle 1 it could reach the allow path. The failure direction is the unchanged deny, and pr-author writes the canonical path (Info).
2. The receipt check is consistency-only; same-session forgery of the parallel checkpoint is disclosed in each header (Info, carried from the prior review).
3. The fix reaches the session root only after merge plus a main sync of the coordinator branch (spec `## Post-Merge Verification`) (Info).

**PR readiness recommendation:** **Ready**; PR CI run 43618612246 on `0f18cbd8e` completed green; no blocking finding.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1` | `AC-12 never throws`, listing-throw row | CR-1 resolved: exact `Should -BeExactly` on the gate's `TARGET_WORKTREE_NOT_DERIVABLE` deny text; leg-level assertions kept. | No change required. | Matches the sibling never-throw rows and the remediation input. | Diff `06cc8b03d..bf508b61c`; run 43615945680 green |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1` | `Get-OrchestrationParallelRecordsRoot`, prefilter after the absolute-shape test | CR-2 resolved: case-sensitive suffix prefilter before any listing or resolver call; row `(h)` pins zero listing calls; fail-before shows the row failing before the fix; bundle copy byte-identical; 136 logical lines. | No change required. | Meets the spec performance constraint for non-receipt absolute paths. | Diff; `evidence/regression-testing/fail-before.2026-11-14T16-07.md`; SHA-256 of both copies |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1` | Prefilter normalization | The prefilter tests the output of `ConvertTo-CleanupContextPath` (slash conversion and one trailing slash only), while the later remainder test uses `ConvertTo-HookTargetWorktreeNormalizedPath` (also trims and collapses repeated slashes). A receipt path with a doubled slash or padding whitespace now declines earlier than before. The outcome is today's deny text, so no allow path widens. Established by code reading; not probed in a process. | No change required; optionally note the stricter form in the header if a future caller writes such paths. | Fail-closed narrowing of a non-canonical spelling that pr-author does not produce. | `.claude/hooks/hook-cleanup-context.ps1` `ConvertTo-CleanupContextPath`; `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` `ConvertTo-HookTargetWorktreeNormalizedPath` |
| Info | `.claude/hooks/pretooluse-dispatch.json` (main, not in the branch diff) | `enforce-test-execution-policy.ps1` registration | Main's new hook runs for the matcher of `Bash` and the two PoshQC MCP tools; the branch legs act on `Write` and `Agent`. No interaction; no shared function name. | No change required. | Composition check after the main merge. | Dispatch registry at the head; function-name comparison |

No Blocker, Major, or Minor finding. No covered file is at or above 700 logical lines, so no file-size Warning row applies.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- No Python change in cycle 1; the appended validator test is unchanged.

#### Typing and API notes

- Not applicable in this cycle.

#### Error handling and logging

- Not applicable to the test-only change.

### TypeScript implementation audit

#### What changed well

- No TypeScript file is in the branch diff.

#### Type safety and maintainability

- Not applicable.

#### Error handling and logging

- Not applicable.

### PowerShell implementation audit

#### What changed well

- The prefilter is a necessary condition of the existing remainder test: any path whose remainder under an enclosing root equals `artifacts/pr_body_<N>.receipt.json` ends with `/artifacts/pr_body_<N>.receipt.json`, so no canonical receipt path that passed before is rejected.
- Case-sensitive `-cnotmatch` matches the existing `-cmatch` and the Linux CI file system.
- The pattern lives in a named script-scope variable beside the existing receipt pattern.

#### API and safety notes

- The leg's return contract and the gate call site are unchanged; the change only removes a process start on the deny path.

#### Error handling and logging

- The early return sits inside the never-throw `try` of `Get-OrchestrationParallelRecordsResult`.

---

## Test Quality Audit

Discrimination was judged from the recorded fail-before run and by inspection. The reviewer ran one parallel Pester gate at the head only to refresh the coverage file the Stop hook requires (26522 tests, 0 failures); no focused run was made. Row `(h)` failed on the listing count before the fix and passes after it. It would also fail if a future change removed the prefilter, because the existing mock of `Get-OrchestrationGateWorktreeList` counts the leg's call. The tightened AC-12 row would fail if this payload ever reached the deny tail with any suffix or a different resolver text.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1`: 297 logical lines.
- `evidence/remediation-baseline/leg-baseline.2026-11-14T15-42.md`, `evidence/other/task-check.P1-T1.2026-11-14T15-44.md`, `task-check.P1-T2.2026-11-14T15-44.md`, `task-check.P2-T1.2026-11-14T16-09.md`, `task-check.P2-T2.2026-11-14T16-09.md`.
- `evidence/qa-gates/phase-gate.P1.2026-11-14T16-07.md`, `phase-gate.P2.2026-11-14T16-29.md`, `final-qc-static-powershell.2026-11-14T16-35.md`, `final-qc-pester.2026-11-14T16-50.md`, `coverage-comparison.2026-11-14T16-50.md`, `final-qc-pytest.2026-11-14T16-51.md`, `self-review.2026-11-14T16-55.md`, `ci-record.2026-11-14T16-56.md`.
- `evidence/regression-testing/fail-before.2026-11-14T16-07.md`.
- `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`: parsed by the reviewer; figures match the evidence (leg 35/35, repo-wide 42209/43953).

### Quality assessment prompts

- **Determinism:** synthetic forward-slash path; mocked seams.
- **Isolation:** one property per row.
- **Speed:** no process start.
- **Diagnostics:** exact-text assertions print both strings.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | No credential or token literal in the diff. |
| No unsafe subprocess or command construction | ✅ PASS | Cycle 1 removes a process start from the deny path; no `Invoke-Expression`. |
| Input validation at boundaries | ✅ PASS | Case-sensitive suffix test before I/O. |
| Error handling remains explicit | ✅ PASS | Decline path unchanged; never-throw contract kept. |
| Configuration / path handling is safe | ✅ PASS | No new path source; non-local forms still rejected first. |

---

## Research Log

No external research was required. The normalizer comparison was made by reading `ConvertTo-CleanupContextPath` and `ConvertTo-HookTargetWorktreeNormalizedPath` at the head.

---

## Verdict

CR-1 and CR-2 are resolved as the remediation inputs require, the main merge composes with the branch without changing its lines or touching its gate surfaces, and the prior review's conclusions still hold. No blocking finding. PR CI run 43618612246 on `0f18cbd8e` completed green, so the branch is ready to merge after the S9 check-off of AC-25.
