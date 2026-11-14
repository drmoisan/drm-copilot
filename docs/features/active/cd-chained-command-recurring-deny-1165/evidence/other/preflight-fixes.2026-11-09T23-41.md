# Preflight Fixes (Issue #1165)

Timestamp: 2026-11-09T23-41
Plan: docs/features/active/cd-chained-command-recurring-deny-1165/plan.2026-11-09T17-40.md

Each fix edits task text only; no task was added, removed, or reordered. A pre-edit copy of the plan is kept as SCRATCH/issue-1165-plan.snapshot.md.

## Fixes

1. [P0-T4] | literal clarification | Stated that the `bash -c "cd /x && git log | head"` row is allowed before the change, with expected values `$false` and `$null`. Observed with a SCRATCH probe that dot-sourced the unedited `.claude/hooks/validate-bash.ps1`: `Get-CdChainedReadCommandMatch` returns `$null` and `Get-BashBlockReason` returns no reason, because the retained pattern needs `&&` or `;` directly before the read word and a pipe precedes `head`.
2. [P1-T2] | literal clarification | Limited the reason-shape Context to the AC-3 to AC-7 commands, matching AC-8 ("all intents above"). The AC-2 `bash -c` row has no reason before or after the change, so a reason-shape assertion on it could never pass.
3. [P1-T2] | disposition citation | Stated that `hook-dependency-failure.Claude.Tests.ps1` derives one row per guarded edge and gains a generated row for the new edge, which passes because the `catch` names the helper. The disposition stays "unchanged file".
4. [P3-T1] | disposition citation | Corrected the reasons given for the brief readers. `planning-contract-wording.Tests.ps1` does read `## Command-Text Restrictions` (`MERGE-TEXT`: `REVIEW_GATE_HEAD_UNRESOLVED`, `git commit -F`), and the edit keeps both tokens. `ProcessReductionChain.Ledger.Tests.ps1` is unchanged because the edits lie outside the recorded revert blocks and stored-patch hunks. Also added `test_single_pass_preflight_contracts.py`, which reads a brief copy, as unchanged.
5. [P3-T2] | disposition citation | Named `tests/scripts/dev-tools/ProcessReductionChain.Ledger.Tests.ps1` as unchanged. The only recorded region of `parallel-orchestrate/SKILL.md`, the 0002 `**Concurrent review.**` revert block, lies outside step (c).
6. [P4-T5] | literal clarification | Limited the `wc -l` check to `.ps1` production files, because Markdown is exempt under the file-size policy. `.claude/skills/parallel-orchestrate/SKILL.md` holds 1392 lines, so the check as written could not pass.
7. [P4-T7] | stale reference | The `acceptance-criteria-tracking` skill names no status value. Replaced the reference with `Implemented`, the value that completed specs use.
