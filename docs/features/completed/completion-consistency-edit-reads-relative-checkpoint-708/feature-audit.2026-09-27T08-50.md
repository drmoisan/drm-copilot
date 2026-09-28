# Feature Audit: Completion-Consistency Edit Reads Relative Checkpoint (#708)

**Audit Date:** 2026-09-27
**Branch:** `bug/completion-consistency-edit-reads-relative-checkpoint-708` @ `d21195cd1da4917c6ce965cc1f032606c72da12c`
**Base:** `origin/main` @ `74b2ca0a2bdf8a0bf9a032433fef20831707b574`

## Scope and Baseline

- Work mode: `full-bug` (marker `- Work Mode: full-bug` in `issue.md`). Acceptance-criteria source: `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/spec.md`, section `## Acceptance Criteria`, 14 checkbox items.
- `issue.md` also contains 4 unchecked checkbox items under `## Acceptance Criteria`. In `full-bug` mode they are not an acceptance-criteria source and are not checked off by this review; their content is covered by spec criteria 1-6, 10, and 11.
- Baseline: the base-commit hook reads `'artifacts/orchestration/orchestrator-state.json'` at line 300 regardless of `tool_input.file_path` (`evidence/baseline/baseline.md` P0-T4, REGION_STATE literal-present). Baseline coverage for the hook is 91.34% lines; baseline bundle copy identical (P0-T5).
- Branch diff: 2 production PowerShell copies (+16/-8 each), 1 new Pester file (227 lines), 9 Markdown feature documents. No `.codex` path changed.
- Plan: `plan.2026-09-26T22-56.md`, 51 of 51 tasks checked.
- Approved design: spec decisions D1-D11 and planner decisions P1-P6 (operator approval 2026-09-26, autonomous mode).
- PR context: regenerated for this review (`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, Head SHA `d21195cd1da4917c6ce965cc1f032606c72da12c` in both).

## Acceptance Criteria Inventory

| # | Criterion (abbreviated) | Source state at review start |
|---|---|---|
| 1 | Raw `tool_input.file_path` reaches the reader unchanged; the literal is no longer passed | checked |
| 2 | `Resolve-EditedCheckpointContent` declares mandatory `-CheckpointPath`; its only caller supplies it from `file_path` | checked |
| 3 | Absolute POSIX target, completion-asserting patch without evidence: deny with `COMPLETION_CONSISTENCY_BLOCKED`; allow pre-fix | checked |
| 4 | Differing content at target and at relative literal: decision follows the target | checked |
| 5 | Relative, absolute, and backslash spellings reach the reader unchanged; relative decisions unchanged | checked |
| 6 | D6 fail semantics unchanged; existing tests pass unmodified | checked |
| 7 | Write-path unchanged; three existing suites pass unmodified | checked |
| 8 | `.DESCRIPTION` and function help describe the targeted read | checked |
| 9 | Bundled copy byte-identical (SHA-256 in evidence) and bundle-parity pytest passes in CI (and locally, #510 handling recorded) | unchecked |
| 10 | Regression tests fail pre-fix and pass post-fix, both runs recorded | checked |
| 11 | Tests use injected reader only; no temp files, `Set-Location`, gitignored state, `origin/main`, Windows-only paths | checked |
| 12 | PoshQC format/analyze clean, test passes, hook line coverage >= 85%, no changed-line regression | checked |
| 13 | No file written exceeds 500 lines | checked |
| 14 | No `.codex` file modified; D11 observations recorded in follow-ups | checked |

## Acceptance Criteria Evaluation

| # | Verdict | Evidence |
|---|---|---|
| 1 | PASS | Diff: line 308 `& $CheckpointReader $CheckpointPath`; line 374 passes `-CheckpointPath $filePath` where `$filePath` is the raw `file_path` (line 359), not `$normalized`. The literal remains only in the activation regex. T-D, T-E, T-F assert exact capture. Reviewer run: pass. |
| 2 | PASS | Lines 291-292 `[Parameter(Mandatory)] [string] $CheckpointPath`; single call site at line 374 (reviewer read of the full file). T-L asserts the mandatory attribute. |
| 3 | PASS | T-A: post-fix deny with `*COMPLETION_CONSISTENCY_BLOCKED*`; against the base-commit hook T-A failed (the pre-fix reader returned `$null` for the literal, producing allow). Reproduced by the reviewer. |
| 4 | PASS | T-B (deny follows target) and T-C (allow follows target) pass post-fix and fail pre-fix. |
| 5 | PASS | T-D, T-E, T-F capture the exact supplied string; T-H confirms relative-path deny; T-E and T-H pass before and after. |
| 6 | PASS | T-G, T-I, T-J, T-K cover the allow rows; envelope anomaly covered by the unmodified `Payload.Tests.ps1` (7/7). `git diff` of the three existing suites against base is empty (`qa-gates.md` P5-T3; reviewer diff stat confirms no change). |
| 7 | PASS | Existing suites 47 + 7 + 15 = 69 pass unmodified (P3-T2); reviewer run 81/81 including the 12 new tests. The Write branch code (content path) is not in the diff. |
| 8 | PASS | `.DESCRIPTION` lines 32-40 and function help lines 272-279 describe reading the Edit's targeted `file_path`; the phrase "are allowed by this hook" is absent from the HEAD file. Minor comment-wording nits are in the code review. |
| 9 | PENDING-CI (non-blocking) | Byte identity: SHA-256 `F9CA16BFBD90E0A2223AB2222C0B7B8F0629DC4D835FF18AD319E407F39F07A5` for both files (P2-T6, P4-T8); reviewer `cmp` identical. Local pytest: 14 passed with D9 option (a) recorded (P4-T7); reviewer re-run 14 passed. The CI result does not exist yet because no PR has been opened. Left unchecked. |
| 10 | PASS | `evidence/regression-testing/edit-target-fail-before.md` (8 failed, 4 passed, hook unmodified) and `edit-target-pass-after.md` (12 passed). Reviewer reproduced both outcomes independently. |
| 11 | PASS | Reviewer read of the full test file: only injected readers; no `TestDrive`, `New-TemporaryFile`, `Set-Location`, `Push-Location`, `git`, `origin/main`, or drive-letter paths. P5-T2 grep counts are 0. |
| 12 | PASS | P4-T1/P4-T2 clean (reviewer re-run clean); P4-T4 1999 passed, 0 failed; hook 92.13% lines (>= 85%); changed lines 308 and 374 covered (P4-T5; reviewer parse of `artifacts/pester/powershell-coverage.xml` confirms `ci=1`). |
| 13 | PASS | 423, 423, and 227 lines (reviewer `wc -l`). Markdown files are exempt. |
| 14 | PASS | No `.codex` path in the branch diff (reviewer check). `evidence/other/follow-ups.md` contains 5 FOLLOW-UP entries, including all three D11 items. |

## Summary

- 13 of 14 criteria evaluated PASS; criterion 9 is PENDING-CI and non-blocking per the caller instruction.
- Findings in this artifact: 0 Blocking, 0 Major, 0 Minor.
- The defect described in issue #708 is corrected for the Claude hook and its bundled copy. The Codex instance remains open by approved design (D7) and is recorded as a follow-up.
- Related minor findings are recorded in `code-review.2026-09-27T08-50.md` (3 Minor) and `policy-audit.2026-09-27T08-50.md` (1 Minor).

## Acceptance Criteria Check-off

- Newly checked off by this review: none. Criteria 1-8 and 10-14 were already checked by the executor, and each was independently re-verified as PASS above.
- Left unchecked: criterion 9, pending the CI result for `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`. Check it off after the PR's CI run passes that test.

### Acceptance Criteria Status
- Source: `docs/features/active/completion-consistency-edit-reads-relative-checkpoint-708/spec.md`
- Total AC items: 14
- Checked off (delivered): 13
- Remaining (unchecked): 1
- Items remaining: criterion 9 — "`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-completion-consistency.ps1` is byte-identical to `.claude/hooks/enforce-completion-consistency.ps1` (matching SHA-256 recorded in evidence), and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes in CI (and locally, with the #510 handling recorded per D9)." Status: PENDING-CI.
