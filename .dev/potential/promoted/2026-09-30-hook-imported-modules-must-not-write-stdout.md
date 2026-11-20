# hook-imported-modules-must-not-write-stdout (Issue #792)

- Date captured: 2026-09-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-imported-modules-must-not-write-stdout/ (Issue #792)
- Related: #690

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #792
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/792
- Last Updated: 2026-09-30
## Summary

A PowerShell module imported by a PreToolUse hook must not write to the success or warning output streams. Under `pwsh -File`, a `Write-Warning` call inside an imported module prints text ahead of the hook's decision JSON, so the hook's output is no longer a single JSON document. The harness treats an unparseable result as non-blocking, so a deny can fail open. The #690 remediation found and fixed one instance; no repository guard prevents the next one.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (also applies to Linux CI under `pwsh`)
- Python version: n/a
- Command/flags used: `pwsh -File .claude/hooks/<hook>.ps1` with a hook payload on stdin
- Data source or fixture: any hook that imports a module from `.claude/lib/` or `.claude/hooks/`

## Steps to Reproduce

1. In a module that a PreToolUse hook imports (for example `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`), add a `Write-Warning` call on a path the hook reaches.
2. Run the hook with `pwsh -File` against a payload that reaches that path and produces a deny decision.
3. Inspect the hook's combined output.

## Expected Behavior

The hook's stdout contains only the decision JSON. Diagnostics from imported modules go to the process error stream.

## Actual Behavior

The warning text precedes the decision JSON, so the output is not parseable as a decision. The #690 remediation recorded this for `Get-WorktreeRunCheckpointText`, which now writes `WORKTREE_RUN_CHECKPOINT_UNREADABLE: ...` through `[Console]::Error.WriteLine` instead (`.claude/lib/worktree-resolution/WorktreeRunResolution.psm1:118`). The rationale is in `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/code-review.2026-09-30T02-35.md` (CR-2) and `remediation-plan.2026-09-30T02-00.md` (Appendix B).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: Verified on main at ae7c7779 that no `.psm1` under `.claude/lib/` or `.claude/hooks/` currently calls `Write-Warning`, `Write-Host`, `Write-Output`, or `Write-Information` (`git grep`). The defect is the missing guard, not a present offender. Hook entry-point scripts legitimately emit the decision with `Write-Output` and must stay outside the guard's scope.

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Not currently reproducible on main. The consequence if it recurs is a silently non-blocking enforcement hook.

## Suspected Cause / Notes

PowerShell routes `Write-Warning` and `Write-Host` output to the host in a way that reaches stdout under `pwsh -File`, and any pipeline output inside a module function becomes part of its return value. Nothing in the repository tests for this.

## Proposed Fix / Validation Ideas

- [ ] Add a repository guard test that scans every module imported by a PreToolUse hook (`.psm1` files and dot-sourced helper scripts, not the hook entry points) for `Write-Warning`, `Write-Host`, `Write-Output`, and `Write-Information`, and fails naming the file and line.
- [ ] Derive the scanned set from the hooks' `Import-Module` and dot-source statements so new modules are covered automatically.
- [ ] The guard test must not create temporary files.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
