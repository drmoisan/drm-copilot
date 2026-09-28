# epic-merge-gate-parses-pr-number-from-whole-command-line (Issue #591)

- Date captured: 2026-08-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-merge-gate-parses-pr-number-from-whole-command-line/ (Issue #591)
- Found during: `/parallel-run bugs-635-440` execution in the destination repository `drmoisan/TaskMaster`, at the per-item pull-request merge gate
- Issue: #591
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/591
- Last Updated: 2026-08-29

## Summary

`Get-EpicMergeGateCommandPrNumber` in `.claude/hooks/enforce-epic-merge-gate.ps1` extracts the pull-request number using two independent `-match` operations. The first confirms the command is a `gh pr merge` invocation; the second then rescans the entire command text for a standalone digit run, with no positional relationship to the `gh pr merge` token. Any digit run appearing earlier in the command line, most commonly inside a `cd` path prefix, is captured instead of the actual pull-request number, and the gate denies a valid merge.

The defect is confined to the second, broadened branch at line 154, added for the parallel command form `gh pr merge --merge 410`. The original epic branch at line 146 is correct because its capture group is anchored inside the `gh pr merge` pattern itself.

## Environment

- OS/version: Windows 11, PowerShell
- Hook: `.claude/hooks/enforce-epic-merge-gate.ps1`, function `Get-EpicMergeGateCommandPrNumber`, line 154
- Command/flags used: `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688`
- Data source or fixture: parallel-orchestrator final report for run `bugs-635-440` in `drmoisan/TaskMaster`, section "Corrections to things I told you earlier"

## Steps to Reproduce

1. Use a worktree whose absolute path contains a standalone digit run, for example `...\TaskMaster-wt\2026-08-29T00-11`.
2. Issue a merge command prefixed with a `cd` into that path: `cd C:\Users\DanMoisan\repos\TaskMaster-wt\2026-08-29T00-11 && gh pr merge --merge 688`.
3. Observe the gate parses the pull-request number as `2026` rather than `688`.
4. The gate denies the command with `EPIC_MERGE_GATE_BLOCKED` because `2026` does not match the checkpoint's pinned `pr_number`.

The bare form `gh pr merge --merge 688`, with no `cd` prefix, is accepted, because the first standalone digit run in that command text happens to be the correct one. The defect is therefore conditional on command shape rather than always active.

## Expected Behavior

The pull-request number is parsed from the `gh pr merge` invocation specifically, meaning the argument following `--merge` or the pull-request number or URL operand of that command, regardless of any other digit runs elsewhere in the command line.

## Actual Behavior

The pull-request number is taken from the first standalone digit run anywhere in the command text, so an unrelated path component supplies it and a legitimate merge is denied.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: the defective expression as it stands at line 154:

```powershell
if ($CommandText -match '(?i)\bgh\s+pr\s+merge\b' -and $CommandText -match '(?<![-\w])(\d+)\b') {
```

For contrast, the correct anchored form at line 146:

```powershell
if ($CommandText -match '(?i)\bgh\s+pr\s+merge\s+(\d+)\b') {
```

Reported verbatim by the parallel-orchestrator: "The merge gate has a real defect. It parses the PR number by scanning the entire command text for the first standalone digit run, so my `cd .../2026-08-29T00-11 && gh pr merge --merge 688` was read as PR `2026` and denied. The checkpoint was correct throughout. Bare commands work."

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Severity is High because the gate fails closed on a correct command. A blocked merge halts a parallel or epic run at the point where the affected item's work is already complete and CI-green, and the failure presents as a governance denial rather than as a parse error, so the operator is given no indication that the cause is the command's path prefix.

## Suspected Cause / Notes

The parallel-form branch was added additively so that epic-path outcomes stayed unchanged, and the comment at lines 149 to 153 records the intent: capture the first standalone run of digits not preceded by `-` or a word character, so a flag token such as `--merge` is not treated as a number and a bare `gh pr merge --merge` still yields `$null`. That reasoning is sound for the argument region but is applied to the whole command line, which is what the expression actually scans.

In the reproduction, `2026` is preceded by a backslash. The lookbehind `(?<![-\w])` excludes only `-` and word characters, and a backslash is neither, so the lookbehind is satisfied and `2026` matches first.

Two constraints any fix must preserve:

- Both branches must continue to return `$null` for a bare `gh pr merge --merge` carrying no number, because downstream logic treats a missing explicit pull-request number as a fail-closed condition.
- The epic-path branch at line 146 must keep its current behavior; the parallel branch was deliberately additive.

## Proposed Fix / Validation Ideas

- [ ] Bind the number capture positionally to the `gh pr merge` invocation rather than scanning the whole command text, for example by matching the flag and its argument together in a single pattern anchored on `gh\s+pr\s+merge`.
- [ ] Do not fix this by widening the lookbehind character class to exclude backslashes. That suppresses this reproduction while leaving the general defect intact, since any digit run appearing before the `gh` token would still be captured.
- [ ] Unit coverage areas: a `cd` prefix whose path contains a standalone digit run followed by `gh pr merge --merge <n>`; the bare `gh pr merge --merge <n>` form; the epic form `gh pr merge <n> --merge`; a bare `gh pr merge --merge` with no number, which must still yield `$null`; and a command whose path prefix contains a digit run adjacent to a word character, which the current lookbehind already excludes.
- [ ] Add a falsifiability check: a test asserting the parsed number equals the argument of `--merge` specifically, so a future rewrite that reintroduces an unanchored scan fails loudly.
- [ ] Sweep the sibling parallel gates for the same unanchored-scan pattern, specifically `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` and `.claude/hooks/enforce-parallel-abandon-gate.ps1`, since the worktree-removal gate keys on a path operand and may share the extraction approach.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
