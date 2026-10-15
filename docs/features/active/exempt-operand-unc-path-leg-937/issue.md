# exempt-operand-unc-path-leg-937 (Issue #937)

- Issue: #937
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/937
- Type: bug
- Follow-up to: #732 (code-review CR-1, Medium); still open per #903 Operator Follow-up 8
- Lifecycle record: docs/features/potential/promoted/2026-10-15-exempt-operand-unc-path-leg-732.md (ref origin/docs/followups-2026-10-15)
- Work Mode: full-bug
- Last Updated: 2026-10-15

> Work-mode note: the issue body records `minor-audit`. The orchestrator selected `full-bug` after eligibility checks because the fix spans four production copies of `enforce-orchestration-preimplementation-gate-targets.ps1` (`.claude/hooks`, `.codex/hooks`, and the two bundled extension resource mirrors), which exceeds the 1-3 production-file minor-audit budget.

## Summary

In the preimplementation gate, a path-leg input spelled as UNC (`\\server\share\...`) or extended-length (`\\?\C:\...`) resolves to the session root instead of its target worktree (#732 CR-1, Medium).

## Environment

- OS/version: any
- Data source or fixture: main at f6915d42

## Steps to Reproduce

1. Call `Get-OrchestrationCommandTarget` with a `git -C \\?\C:\...` or UNC path to a worktree; it normalizes to `//...`, fails `$script:OrchestrationTargetAbsolutePattern` (targets.ps1 line 31) and resolves to the session root.

## Expected Behavior

UNC and extended-length paths resolve to the worktree they name, or are denied as unresolvable.

## Actual Behavior

They resolve to the session root, so a gate can evaluate the wrong checkpoint.

## Logs / Screenshots

- #732 `code-review.2026-10-09T05-42.md` CR-1 (reviewer probe `probe732.ps1`).

## Impact / Severity

- Medium

## Suspected Cause / Notes

Affects all four copies of `enforce-orchestration-preimplementation-gate-targets.ps1` (path-leg loop at line 201). Not a regression relative to the pre-#732 base.

## Proposed Fix / Validation Ideas

- Normalize `\\?\` and UNC spellings before the absolute-path check, or deny them as unresolvable (fail closed).
- Add test rows for both spellings on both surfaces; update mirrors.

## Acceptance Criteria

Acceptance criteria for this `full-bug` item are authored in `spec.md`, which is the AC source for this work mode.
