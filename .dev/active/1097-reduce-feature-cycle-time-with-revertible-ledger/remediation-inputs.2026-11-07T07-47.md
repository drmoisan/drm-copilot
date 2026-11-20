# Remediation Inputs — Issue 1097

Timestamp: 2026-11-07T07-47
Review-Verdict: REMEDIATION_REQUIRED
Remediation-Mode: proportionate
Source review artifacts:
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/policy-audit.2026-11-07T07-47.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/code-review.2026-11-07T07-47.md`
- `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/feature-audit.2026-11-07T07-47.md`
Head reviewed: `0a09dacd33e01be591869a949ff373b5f83fbb88` (merge base `278bb7047db986bbb0a8652ca323656ce85f8a08`)
Remediation plan target: `docs/features/active/reduce-feature-cycle-time-with-revertible-ledger-1097/remediation-plan.2026-11-07T07-47.md`

This file supersedes `remediation-inputs.2026-11-07T06-35.md`, because the orchestrator reads the highest timestamp. That file covered stage B at another head.

## Findings requiring remediation

### F1 — Merge commands the gate does not read bypass the review guard

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is a key-gated check in hook files already in the branch diff, plus test rows and text; it needs no external party, policy decision, owner input, or CI result.

- Files: `.claude/hooks/enforce-epic-merge-gate.ps1` (scope return at line 356), `.codex/hooks/enforce-epic-merge-gate.ps1` (line 157), `.claude/hooks/enforce-epic-merge-gate-review.ps1` and its byte-identical Codex twin (header lines 8 and 9), their bundled copies, the case table `tests/scripts/claude-hooks/EpicMergeGateReview.Cases.Helpers.ps1`, and `.claude/rules/orchestrator-state.md` with its bundled copy.
- Problem: under `review_mode: "concurrent"` with no passing review, the real gate process returned `allow` for these commands:
  - `if gh pr checks 1101; then gh pr merge 1101 --merge; fi`
  - `exec gh pr merge 1101 --merge`
  - `! gh pr merge 1101 --merge`

  `Test-EpicMergeGateCommandInScope` finds no structural match in them, so both gates allow before the guard runs. Separately, `Get-EpicMergeGateSelectorPrNumber` reads only the first match, so with a passing first number on the epic-child path, `gh pr merge 1101 --merge; gh pr merge --merge` and `gh pr merge 1101 --merge && gh pr merge 1100 --merge` returned `allow` and the second merge was never examined. The guard header states that a checkpoint with the key "cannot reach an allow branch without a passing review at a current head", and `spec.md` D10 does not list this limit, so owner condition 3 is not met as written. The scanner gap predates this branch; `enforce-epic-merge-gate-command.ps1` is not in the diff. The branch makes this gate the only merge-time review control.
- Required change:
  1. Keep the no-key behavior byte-identical. Criterion `[C]` forbids a new denial without the key, so do not widen `Test-EpicMergeGateCommandInScope` or the shared scanner for every run.
  2. In both gates, before the out-of-scope allow: when the command text names `gh`, `pr`, and `merge` but has no structural match, read the session checkpoint and deny with `REVIEW_GATE_HEAD_UNRESOLVED` when it carries the key. Without the key, return the existing allow.
  3. Under the key, deny a command that holds more than one merge invocation, with the same code, so a second merge cannot pass unread. Do not reuse `Get-DocsOnlyMergeShapeViolation` without checking its `--auto` rule first, because it rejects shapes the concurrent path may need.
  4. Correct the guard header, in all four copies. Name any shape that stays unread in the honest disclosure of `.claude/rules/orchestrator-state.md` and in `spec.md` D10. The rule section is a `Current` block of entry `0002`, so update the entry in the same commit (K3).
- Verification required: (a) new rows in the shared table run through both gates and cover the three wrapper forms and the two chain forms with the key, each denied; (b) the same commands without the key keep their current result, with no `gh` call; (c) the guard stays byte-identical across the four copies (`cmp`); (d) a real-process run of the gate confirms the wrapper forms deny, because the existing rows mock the process seams; (e) `Test-ProcessReductionLedger` is valid and the replay of entry `0002` still equals the `origin/main` text; (f) format, lint, then one `Invoke-PoshQCParallelTest` run.

## Non-remediation items (record only; recommended for the same cycle)

These are from `code-review.2026-11-07T07-47.md`. None stops the merge.

- F3, Minor: state in item 3 of the concurrent section that the entry's PR number is committed after the pull request opens and before `head_sha` is read, in all copies, and update the entry's `Current` blocks.
- F4, Minor: make the PowerShell readiness read of `review_mode` ordinal on the key name, and add a row. A `Review_Mode` key now relaxes readiness while the guard stays inert.
- F5, Minor: add the key and `head_sha` to `.agents/skills/orchestrator-state/SKILL.md` and its bundled copy. Owed by stage I at the latest.
- F6, Nit: name `ConvertFrom-DocsOnlyNameList` in the guard `.NOTES` while the header is open.
- F2, Minor: no action. The token mismatch on `ee44aaa86` and `759600565` is disclosed in the entry and cannot be fixed without a forced push; it is listed for owner ratification.

## Constraints

- Tests run in parallel only, per `spec.md` `## Testing Rule`: one `Invoke-PoshQCParallelTest` run, one `pytest -n auto` run if a Python file changes, re-run only after a fix.
- Do not change baseline, coverage-comparison, or `N/A - no pre-change run` text; a coordinator hold is in force.
- Any code commit makes this review stale, so a re-review follows. Commit any `Merge commit:` number change before the re-review starts.
- Re-check the two `[C]` criteria only after re-review; the reviewer unchecked them in `spec.md` and `user-story.md`. These checkbox edits are uncommitted in the worktree beside this file.
- Stage C reduces nothing further, so no new ledger entry is owed. An edit to `0002` keeps the `reduction: 0002` token in its commit subject.
- `enforce-epic-merge-gate.ps1` is at 492 logical lines, so put new logic in the review sibling. Keep guard files in step across all four copies.
- No Epic #1019 folder, `execution-environment`, or `atomic-plan-contract` file is edited.
