# exempt-operand-unc-path-leg-732 (Issue #937)

- Date captured: 2026-10-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/exempt-operand-unc-path-leg-732/ (Issue #937)
- Work Mode: minor-audit

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #937
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/937
- Last Updated: 2026-10-15
## Summary

In the preimplementation gate, a path-leg input spelled as UNC (\\server\share\...) or extended-length (\\?\C:\...) resolves to the session root instead of its target worktree (#732 CR-1, Medium). Still open per #903 Operator Follow-up 8.

## Environment

- OS/version: any
- Python version: n/a
- Command/flags used: see Steps
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Call ``Get-OrchestrationCommandTarget`` with a ``git -C \\?\C:\...`` or UNC path to a worktree; it normalizes to ``//...``, fails ``$script:OrchestrationTargetAbsolutePattern`` (targets.ps1 line 31) and resolves to the session root.

## Expected Behavior

UNC and extended-length paths resolve to the worktree they name, or are denied as unresolvable.

## Actual Behavior

They resolve to the session root, so a gate can evaluate the wrong checkpoint.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: #732 code-review.2026-10-09T05-42.md CR-1 (reviewer probe probe732.ps1).

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

## Suspected Cause / Notes

Affects all four copies of enforce-orchestration-preimplementation-gate-targets.ps1 (path-leg loop at line 201). Not a regression relative to the pre-#732 base.

## Proposed Fix / Validation Ideas

- [ ] Normalize \\?\ and UNC spellings before the absolute-path check, or deny them as unresolvable (fail closed).
- [ ] Add test rows for both spellings on both surfaces; update mirrors.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch