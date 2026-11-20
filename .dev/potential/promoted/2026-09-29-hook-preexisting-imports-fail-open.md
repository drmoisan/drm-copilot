# hook-preexisting-imports-fail-open (Issue #786)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/hook-preexisting-imports-fail-open/ (Issue #786)
- Related: #690

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #786
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/786
- Last Updated: 2026-09-30
## Summary

#690 added a guarded import of `WorktreeRunResolution.psm1` to the gates it converted, so a failed import records the failure and denies. Other module imports and dot-sources in PreToolUse hooks are not guarded in the same way. When one of them fails, the hook exits non-zero with no decision JSON. PreToolUse treats a non-zero exit other than a deny as non-blocking, so the gate fails open.

## Environment

- OS/version: Windows 11 Pro 10.0.26200 (PowerShell 7)
- Python version: n/a
- Command/flags used: `pwsh -File .claude/hooks/<hook>.ps1` with a PreToolUse payload on stdin
- Data source or fixture: hooks under `.claude/hooks/` at main ae7c7779

## Steps to Reproduce

1. Make one imported dependency of an unguarded hook fail to load (for example `HookPayload.psm1` or `EpicScopeResolution.psm1`) using a test seam, without renaming or moving files.
2. Run the hook with a payload that the gate would normally deny.
3. Inspect the exit code and stdout.

## Expected Behavior

The hook records the failed import or dot-source and emits a deny decision that names the failed dependency.

## Actual Behavior

The hook terminates at the import statement and exits non-zero without a decision. Examples verified by reading main: `enforce-model-routing-receipt.ps1:50` (`HookPayload.psm1`, no error action), `:53` and `:55` (`WorktreeItemResolution.psm1` and `EpicScopeResolution.psm1` with `-ErrorAction Stop` and a comment that the import is deliberately unguarded and fail-closed); `enforce-pr-author-skill.ps1:47` and `:53` (`HookPayload.psm1`, `OrchestratorState.psm1`) and the dot-sources at `:146` and `:150`. `EpicScopeResolution.psm1` reaches `WorktreeRunResolution.psm1`, so the #690 guard does not cover these two hooks. The code comment at `enforce-model-routing-receipt.ps1:51-52` assumes an unguarded failure is fail-closed; under the exit-code rule above it is not. Other hooks not converted by #690 that import modules or dot-source siblings are in scope (the dependency list is to be enumerated by the fix).

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: no captured failing run. The fail-open consequence follows from the hook exit-code contract and has not been demonstrated end to end in this entry.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A gate whose dependency fails to load stops enforcing, silently.

## Suspected Cause / Notes

- A guard that catches too broadly can hide a real parse error in the hook itself; the guard must cover only the import statement.
- Hooks that dot-source helpers define functions the decision path needs; the deny must be emitted before any of those functions is called.

## Proposed Fix / Validation Ideas

- [ ] Every PreToolUse hook under `.claude/hooks/` that imports a module or dot-sources a sibling script records a failed load and emits a deny naming the dependency.
- [ ] A test simulates the failure for each hook without renaming, moving, or creating files.
- [ ] Every changed primary file is byte-identical to its bundle mirror.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
