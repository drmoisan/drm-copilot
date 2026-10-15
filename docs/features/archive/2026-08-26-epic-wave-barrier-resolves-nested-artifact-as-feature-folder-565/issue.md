# epic-wave-barrier-resolves-nested-artifact-as-feature-folder (Issue #565)

- Date captured: 2026-08-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/epic-wave-barrier-resolves-nested-artifact-as-feature-folder/ (Issue #565)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #565
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/565
- Last Updated: 2026-08-26
- Work Mode: full-bug

## Summary

`.claude/hooks/enforce-epic-wave-barrier.ps1` resolves a feature folder from prompt text by longest match. When a delegation prompt cites a nested artifact path, the longest match is the artifact path rather than the feature folder, so the epic wave barrier issues a false block. This is the same defect fixed for `enforce-prd-feature-before-planner.ps1` under issue #518, which explicitly deferred this hook to its own issue.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7.6.5
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: any agent delegation whose prompt cites a nested artifact path under a feature folder, for example `docs/features/active/<folder>/research/<file>.md`
- Data source or fixture: `.claude/hooks/enforce-epic-wave-barrier.ps1` line 99

## Steps to Reproduce

1. Prepare an active feature folder whose records legitimately satisfy the gate.
2. Issue a delegation whose prompt cites a nested artifact path under that folder — a `research/` or `evidence/<kind>/` path — rather than citing the feature folder alone.
3. Observe the hook's resolved folder.

## Expected Behavior

The hook resolves the feature folder to `docs/features/active/<folder>` for every prompt form, whether the prompt cites the folder alone, the folder plus a nested artifact, or a nested artifact alone. The decision is identical in all cases.

## Actual Behavior

The selection rule `Sort-Object -Property Length -Descending` at line 99 returns the longest matched token, which for a nested citation is the artifact path. The basename resolves to `research` or `evidence` instead of the feature folder, the record lookup fails, and the hook issues a false block.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see the reproduction and root-cause analysis recorded under issue #518 at `docs/features/completed/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`, sections "Repro & Evidence" and "Root Cause Analysis", and the research artifact in that folder's `research/` subtree, section 4, which enumerates all four affected hooks.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

A false block halts a correctly-formed delegation. The failure is silent in the sense that the block reason names a folder the operator never cited, so the cause is not obvious from the message.

## Suspected Cause / Notes

Longest-match is the wrong selection rule. The feature folder is identifiable structurally, not by length: it is the path segment immediately below `docs/features/active/`. A repository-wide search for `Sort-Object -Property Length -Descending` returns exactly eight files — four self-hosted hooks and their four bundled mirrors — and nothing else.

Issue #518 fixed one of the four. It was scoped to a single hook because fixing all four means eight production files once the mandatory bundled mirrors are counted, which exceeds both the 3-production-file batch cap and the 2-production-file direct-mode cap in `.claude/rules/powershell.md:37-40`.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: folder resolution across all four prompt forms; deterministic selection when a prompt names two distinct feature folders; rejection of a token that truncates to fewer than four segments.
- [x] Integration scenario to retest: the hook's own Pester test file, plus `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`, which asserts text parity between the self-hosted hook and its bundled mirror.
- [x] Manual verification notes: apply the reference implementation landed by #518 in `.claude/hooks/enforce-prd-feature-before-planner.ps1` — normalize each match to forward slashes, truncate to exactly four path segments, deduplicate with an order-preserving collection, then prefer the checkpoint-recorded folder and fall back to the earliest occurrence.

Scope is the hook, its bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1`, and its Pester test file. Editing the mirror is not optional.

Note that #518 deliberately did NOT extract a shared helper module: that would force a new bundled mirror plus two `pester.runsettings.psd1` edits, a larger write set than the duplication it removes, and none of the affected hooks is near the 500-line limit. Re-evaluate only if that changes.

Known adjacent limitation, carried and not introduced: the matching regex captures trailing punctuation into the token, so a folder path ending a prose sentence is captured with the period or comma attached. #518 recorded this and left it unchanged.

## Consolidated Scope (Issue #565 Comments)

The three consolidation comments on #565 widen the primary scope beyond `enforce-epic-wave-barrier.ps1`. The same root cause (a feature folder chosen by longest `docs/features/active/...` match, or by longest folder name, rather than by the declared target) is fixed in each of the following, together with their `.codex/hooks/` copies where one exists and their bundled mirrors under `extensions/drm-copilot/resources/`:

- `.claude/hooks/enforce-epic-wave-barrier.ps1` (this issue).
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1` near line 150 (consolidated #566).
- `.claude/hooks/enforce-parallel-drift-gate.ps1` near line 196 (consolidated #567).
- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` near line 236.
- The epic child-launch gate that denied the #621 launch during epic #770 because the prompt cited the longer feature-folder name belonging to #508.

Resolution anchors on the declared target folder, not on match length. PR #569 (#518) is the reference fix.

## Bundled Issues

This child of epic #852 (enforcement-hook-precision, child C2) also delivers the following existing issues. Each is closed by the same pull request.

### #568 — feature-folder-order hook: work-mode and plan-filename defects

Acceptance conditions:

- `.claude/hooks/enforce-feature-folder-order.ps1` resolves the required prerequisite set from the persisted `- Work Mode:` marker in `issue.md`: `minor-audit` requires `issue.md` alone; `full-bug` requires `issue.md` and `spec.md`; `full-feature` requires `issue.md`, `spec.md`, and `user-story.md`; legacy `full` normalizes to `full-feature`; a missing or malformed marker fails closed to the `full-feature` set.
- The hook fires for timestamped plan artifacts (for example `plan.2026-08-23T23-22.md`) as well as a literal `plan.md`.
- A correctly-formed `full-bug` or `minor-audit` plan write is allowed; a plan write missing a mode-required prerequisite is denied.

### #696 — direct coverage of `Get-PrdFeatureCheckpointFolder`

Acceptance conditions:

- `Get-PrdFeatureCheckpointFolder` in `.claude/hooks/enforce-prd-feature-before-planner.ps1` has direct Pester coverage of its read, parse, and field-extraction body (not only the absent-file early return, and not via a mock of the function itself).
- The tests exercise the mandatory absolute `-CheckpointPath` contract introduced by PR #695 (issues #673 and #672), including a present checkpoint with a recorded feature folder, a checkpoint without that field, and an unparseable checkpoint.
- The tests create no temporary files.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
