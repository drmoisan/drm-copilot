# Self-Review, remediation cycle 1 (issue #1163, [P0-T1], finding F1)

Timestamp: 2026-11-13T14-55
Command: walk of docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md, code-review.yyyy-MM-ddTHH-mm.md, and feature-audit.yyyy-MM-ddTHH-mm.md against `git diff <merge base of origin/main and HEAD> HEAD`, with the cycle change read from `git diff` of the review-inputs commit ("docs(1163): record feature review and light remediation inputs") to HEAD
EXIT_CODE: 0
Output Summary: No FAIL row. Finding F1 of remediation-inputs.2026-11-13T14-23.md is fixed: `Resolve-AgentTargetWorktree` keeps `$branches` an array and names the `Branch` and `Root` of the first matching dropped record, so a single `branch: bug/item` label or `-CommandBranch 'bug/item'` over a prunable-only registration now yields `branch 'bug/item' is registered only at the stale root ...`. The two AC-7 rows now require the full branch name; they failed before the fix (500 passed, 4 failed) and pass after it (504 passed, 0 failed). Final QA loop: static 0 rewritten and 0 findings, Pester 21666 tests and 0 failures, leak scan 0 failures, pytest contracts 198 passed, Codex generator check exit 0, sources and mirrors byte-identical. Rows of self-review.2026-11-13T14-12.md that this cycle does not touch stand as recorded there.

Evidence used (feature `evidence/` folder): regression-testing/fail-before.F1.2026-11-13T14-33.md, other/task-check.P0-T1.2026-11-13T14-36.md, qa-gates/powershell-static-final.2026-11-13T14-38.md, qa-gates/codex-generator-check-final.2026-11-13T14-38.md, qa-gates/pester-parallel-final.2026-11-13T14-54.md, qa-gates/leak-scan.2026-11-13T14-54.md, qa-gates/pytest-contracts-final.2026-11-13T14-54.md; Phase 0 baseline baseline/pester-parallel.2026-11-10T04-07.md.

## Cycle change

| File | Change |
|---|---|
| `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | `Resolve-AgentTargetWorktree`: `$branches = @(if (...) { ... } else { ... })` with a why comment; `$stale` holds the matching dropped records; the detail reads `$stale[0].Branch` and `$stale[0].Root`. |
| `.codex/hooks/agent-target-worktree.ps1` | Same function text. |
| Two bundle mirrors under `extensions/drm-copilot/resources/` | Copied; SHA-256 equal to the sources. |
| `tests/scripts/claude-lib/worktree-resolution/AgentTargetWorktree.Rows.Helpers.ps1` | Two `DetailPattern` values require `branch 'bug/item'` before the stale root. |

## Policy audit template

| Item | Status | Evidence |
|---|---|---|
| Coverage metrics by language (PowerShell) | PASS | Repo-wide 95.83% (baseline 95.80%); the two changed files 98.77% and 98.72%, equal to the 2026-11-13T14-09 run; changed lines 4 of 4 covered in each file. |
| Python, Bash, TypeScript, JSON rows | N/A | No file of these kinds changed in this cycle; 0 `.py` paths on the branch. |
| Baseline and post-change coverage artifacts | PASS | baseline/pester-parallel.2026-11-10T04-07.md; qa-gates/pester-parallel-final.2026-11-13T14-54.md. |
| Fail-closed rule (no missing artifact) | PASS | Every artifact listed above exists. |
| Temporary artifacts cleanup | PASS | Launchers live in SCRATCH; the cycle diff holds only the planned files and evidence. |
| 1.1 Independence, isolation, determinism | PASS | Data rows with in-memory porcelain; pass inside the parallel gate; leak scan 0 failures. |
| 1.1 Fast execution | PASS | Each row runs in about 20 ms (task-check output). |
| 1.2 No coverage regression | PASS | No per-file or repo-wide drop. |
| 1.2 New/changed code coverage at or above 90% | PASS | 100% of changed lines. |
| 1.2 Negative flows and edge cases | PASS | The rows exercise the one-branch case that F1 describes for both sources (command branch and prompt label); the two-label ambiguity rows are unchanged and pass. |
| 1.3 Clear failure messages | PASS | `Should -Match` on the pattern prints the actual detail, which showed `branch 'b'` before the fix. |
| 1.4 No external dependencies, no temporary files | PASS | No file, process, or clock access in the rows. |
| 2.2 Simplicity | PASS | The fix removes the index into `$branches` and reads the matched record directly. |
| 2.3 File size | PASS | The module has 207 lines and the twin 201 (`wc -l`); the rows helper is unchanged in line count. |
| 2.4 Comment why | PASS | The added comment states why `@()` wraps the whole `if`. |
| 2.5 Formatting, linting | PASS | qa-gates/powershell-static-final.2026-11-13T14-38.md: 0 rewritten, 0 findings. |
| 2.5 Type checking | N/A | Not applicable to PowerShell. |
| 2.5 Testing and full loop | PASS | One clean pass of the loop; no step changed a file or failed. |
| 2.x Error handling | PASS | No catch or error path added or changed. |
| 3B PowerShell code policy | PASS | PowerShell 7 syntax; no global state; function text identical in the twin. |
| 4B PowerShell test policy | PASS | Pester 6 rows in the shared helper; run by the PoshQC parallel gate. |
| 6 Total tests / failed | PASS | 21666 tests, 0 failures, 0 errors. |
| 7 Pre-existing failures | PASS | None in the baseline and none in the gate. |
| Evidence holds no absolute path or host name | PASS | Pattern scan of every evidence file added in this cycle returned no match. |

## Code review template

| Item | Status | Evidence |
|---|---|---|
| Findings: Blocker or Major | PASS | F1 (Blocking) fixed; no new finding. |
| Correctness | PASS | `$stale[0].Branch` is the registered short name (the porcelain parser strips `refs/heads/`), so the detail names the branch as registered; the matching is unchanged (ordinal, case-insensitive). With two labels, the detail names the branch whose record matched, not merely the first label. |
| Mirror and twin parity | PASS | SHA-256 pairs equal; `agent-target-worktree.Tests.ps1` holds the function text equal. |
| Security: input handling and command construction | PASS | No new input or command; the detail is an interpolated string of parsed values only. |
| Invariant paths unchanged | PASS | `HookTargetWorktree.psm1`, `hook-target-worktree.ps1`, `.claude/settings.json`, `.codex/config.toml`, and the leak allowlist are unchanged against the merge base. |
| Verdict | PASS | Ready for re-review. |

## Feature audit template (AC source: spec.md, full-bug)

| AC | Status | Evidence |
|---|---|---|
| AC-7 | PASS | The prunable-only rows now require the full branch name, the stale root, and `git worktree repair`, and pass in the gate. |
| AC-2, AC-27 | PASS | Twin function text and mirror bytes equal after the re-copy. |
| AC-3, AC-24, AC-31 | PASS | Invariant files unchanged; no `.py` path. |
| AC-33 | PASS | One parallel run with 0 failures; both changed files above 85%; evidence holds no absolute path. |
| AC-1, AC-4 to AC-6, AC-8 to AC-23, AC-25, AC-26, AC-28 to AC-30, AC-32 | PASS | Unaffected by this cycle; as recorded in self-review.2026-11-13T14-12.md, and their suites pass in this gate. |
| AC-34 | N/A | CI-dependent; verified at S9 by the item's orchestrator. |

### AC Status Summary

- Source: docs/features/active/2026-11-09-hook-session-root-resolution-1163/spec.md
- Total AC items: 34
- Checked off (delivered): 33
- Remaining (unchecked): 1
- Items remaining: AC-34 (CI-dependent; S9)
