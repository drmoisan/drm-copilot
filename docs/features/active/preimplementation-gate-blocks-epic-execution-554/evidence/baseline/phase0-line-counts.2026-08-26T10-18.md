# Phase 0 — Line-Count Baseline (issue #554)

Timestamp: 2026-08-26T10-18

Command:

```powershell
foreach ($p in @(
  '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1',
  '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1',
  'tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1')) {
  $c = (Get-Content -LiteralPath $p).Count
  '{0}  GetContentLines={1}' -f $p, $c
}
```

EXIT_CODE: 0

Output Summary:

| File | Lines | Headroom against the 500-line cap |
| --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | **382** | **118** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | **382** | **118** |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1` | **461** | **39** |

Three integer line counts: 382, 382, 461. Three integer headroom values: 118, 118, 39.

These agree with the counts recorded in the research pass (section A1 and section G2).

## Two Measurement Notes

**(a) `wc -l` under-reports the Claude hook by one.** A cross-check with `wc -l` returned 381 for
`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and 382 for the Codex copy. `wc -l`
counts newline characters, and the Claude hook does not end with a trailing newline while the Codex
copy does. `Get-Content ... .Count` reports 382 content lines for both, which is the figure recorded
above and the figure the 500-line cap is measured against.

**(b) The trailing-byte difference is carried forward as a mirror-copy constraint.** The Claude gate
hook has no trailing newline; the Codex gate hook has one. Any mirror copy performed in Phase 4 must
be a byte-copy that preserves this, because SHA-256 pair verification observes a trailing-byte
difference where the repository's Python parity tests (which compare `read_text()` results under
universal-newline translation) cannot.

## Headroom Consequence

The 39 lines of headroom on `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1`
is the reason every new Claude-side case is authored in the new sibling suite
`tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
rather than in the existing suite. That existing suite must not grow and must not be edited.
