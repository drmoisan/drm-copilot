# feature-folder-order-hook-work-mode-and-plan-filename-defects (Issue #568)

- Date captured: 2026-08-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/feature-folder-order-hook-work-mode-and-plan-filename-defects/ (Issue #568)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #568
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/568
- Last Updated: 2026-08-26
## Summary

`.claude/hooks/enforce-feature-folder-order.ps1` carries two independent defects: it demands the
`full-feature` prerequisite set unconditionally with no work-mode awareness, and its path regex
requires a literal `plan.md`, which the repository's prevailing timestamped plan-artifact convention
does not match. Both were found while scoping issue #518 and were recorded there as explicitly
excluded, to be filed separately.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7.6.5
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: any plan write into an active feature folder
- Data source or fixture: `.claude/hooks/enforce-feature-folder-order.ps1` lines 62, 87, and 120

## Steps to Reproduce

Defect A — prerequisite set:

1. Prepare an active feature folder whose `issue.md` carries `- Work Mode: full-bug`, with `spec.md`
   present and `user-story.md` correctly absent.
2. Attempt a plan write to a file literally named `plan.md` in that folder.
3. Observe that the hook blocks, naming `user-story.md` as missing.

Defect B — plan filename:

1. Prepare any active feature folder.
2. Attempt a plan write to a timestamped artifact such as `plan.2026-08-23T23-22.md`.
3. Observe that the hook does not fire at all.

## Expected Behavior

Defect A: the hook resolves the required prerequisite set from the persisted `- Work Mode:` marker.
`minor-audit` requires `issue.md` alone; `full-bug` requires `issue.md` and `spec.md`;
`full-feature` requires all three. Legacy `full` normalizes to `full-feature`.

Defect B: the hook fires for the plan artifacts actually being written, including timestamped ones.

## Actual Behavior

Defect A: line 62 demands `issue.md`, `spec.md`, and `user-story.md` unconditionally. That set is
correct only for `full-feature`. It contradicts
`.claude/skills/feature-promotion-lifecycle/SKILL.md:111`, under which `minor-audit` expects
`issue.md` alone and `full-bug` expects `issue.md` and `spec.md` with `user-story.md` absent unless
explicitly justified. A correctly-formed `full-bug` or `minor-audit` plan write is therefore blocked.

Defect B: the path test at line 87 is a strictly anchored regex whose match must end in a literal
`plan.md`. A timestamped plan artifact does not match, so the hook is inert in the common case and
enforces nothing.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: recorded under issue #518 at
  `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`,
  section "Scope & Non-Goals", subsection "Explicitly excluded systems, integrations, or datasets".

## Impact / Severity

- [ ] Blocker
- [ ] High
- [x] Medium
- [ ] Low

Defect B currently masks Defect A, so neither is observed in normal operation. The severity is the
combined risk: a gate that enforces nothing today and would block correctly-formed work the moment
its regex is corrected.

## Suspected Cause / Notes

This hook does **not** carry the `Sort-Object -Property Length -Descending` selection rule fixed under
#518 and needs no folder-resolution edit. It reads `file_path` from the tool payload at line 120
rather than scanning prompt text, and its line-87 regex has a `[^/]+` segment that forbids a nested
path, so it is structurally immune to that defect. The two defects here are unrelated to it.

Note the interaction: fixing the regex without also fixing the prerequisite set would convert a
silently-inert hook into one that actively blocks correctly-formed `full-bug` and `minor-audit` plan
writes. Fix both together, or fix Defect A first.

Defect A is the same class of failure #518 fixed in the prd-feature gate: a fail-closed set that is
wrong for two of the three work modes.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: prerequisite-set resolution for each of `minor-audit`, `full-bug`,
  `full-feature`, and legacy `full`; a distinct indeterminate-marker block reason when the marker is
  absent, unreadable, or unrecognized; regex acceptance of both `plan.md` and the timestamped form.
- [x] Integration scenario to retest: `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1`,
  plus `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, which asserts text
  parity between the hook and its bundled mirror.
- [x] Manual verification notes: `Get-PrdFeatureRequiredFile` and the indeterminate-marker branch
  landed by #518 in `.claude/hooks/enforce-prd-feature-before-planner.ps1` are a working reference for
  Defect A.

Scope is `.claude/hooks/enforce-feature-folder-order.ps1`, its bundled mirror at
`extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-feature-folder-order.ps1`,
and `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1`. Editing the mirror is not
optional.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
