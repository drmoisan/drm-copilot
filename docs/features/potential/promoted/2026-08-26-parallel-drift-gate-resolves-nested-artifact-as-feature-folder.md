# parallel-drift-gate-resolves-nested-artifact-as-feature-folder (Issue #567)

- Date captured: 2026-08-26
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/parallel-drift-gate-resolves-nested-artifact-as-feature-folder/ (Issue #567)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #567
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/567
- Last Updated: 2026-08-26
## Summary

`.claude/hooks/enforce-parallel-drift-gate.ps1` resolves a feature folder from prompt text by longest match. When a delegation prompt cites a nested artifact path, the longest match is the artifact path rather than the feature folder, so the parallel drift gate issues a false block. This is the same defect fixed for `enforce-prd-feature-before-planner.ps1` under issue #518, which explicitly deferred this hook to its own issue.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; PowerShell 7.6.5
- Python version: not applicable (PowerShell PreToolUse hook)
- Command/flags used: any agent delegation whose prompt cites a nested artifact path under a feature folder, for example `docs/features/active/<folder>/research/<file>.md`
- Data source or fixture: `.claude/hooks/enforce-parallel-drift-gate.ps1` line 196

## Steps to Reproduce

1. Prepare an active feature folder whose records legitimately satisfy the gate.
2. Issue a delegation whose prompt cites a nested artifact path under that folder — a `research/` or `evidence/<kind>/` path — rather than citing the feature folder alone.
3. Observe the hook's resolved folder.

## Expected Behavior

The hook resolves the feature folder to `docs/features/active/<folder>` for every prompt form, whether the prompt cites the folder alone, the folder plus a nested artifact, or a nested artifact alone. The decision is identical in all cases.

## Actual Behavior

The selection rule `Sort-Object -Property Length -Descending` at line 196 returns the longest matched token, which for a nested citation is the artifact path. The basename resolves to `research` or `evidence` instead of the feature folder, the record lookup fails, and the hook issues a false block.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: see the reproduction and root-cause analysis recorded under issue #518 at `docs/features/active/2026-08-23-prd-feature-gate-resolves-nested-artifact-as-feature-folder-518/spec.md`, sections "Repro & Evidence" and "Root Cause Analysis", and the research artifact in that folder's `research/` subtree, section 4, which enumerates all four affected hooks.

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

Scope is the hook, its bundled mirror at `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1`, and its Pester test file. Editing the mirror is not optional.

Note that #518 deliberately did NOT extract a shared helper module: that would force a new bundled mirror plus two `pester.runsettings.psd1` edits, a larger write set than the duplication it removes, and none of the affected hooks is near the 500-line limit. Re-evaluate only if that changes.

Known adjacent limitation, carried and not introduced: the matching regex captures trailing punctuation into the token, so a folder path ending a prose sentence is captured with the period or comma attached. #518 recorded this and left it unchanged.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
