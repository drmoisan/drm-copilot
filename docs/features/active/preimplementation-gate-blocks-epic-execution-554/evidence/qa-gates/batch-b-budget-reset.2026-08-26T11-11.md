# Batch B — PowerShell Per-Batch Budget Counter Reset (issue #554)

Timestamp: 2026-08-26T11-11

Command:

```powershell
Get-ChildItem -Path '.claude/state' -Filter 'powershell-batch-budget.*.json' | Remove-Item -Force
```

EXIT_CODE: 0

Output Summary:

**One counter file existed and was deleted; none remains.**

| Stage | Files matching `.claude/state/powershell-batch-budget.*.json` |
| --- | --- |
| Before deletion | **1** — `.claude/state/powershell-batch-budget.default.json` |
| After deletion | **0** |

A listing of `.claude/state/` after the deletion is empty, so no `powershell-batch-budget` counter
file remains.

## Counter Contents Observed Before Deletion

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    ".claude/hooks/enforce-orchestration-preimplementation-gate.ps1",
    ".codex/hooks/enforce-orchestration-preimplementation-gate.ps1"
  ],
  "testFiles": [
    "tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1",
    "tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1"
  ]
}
```

The recorded paths are absolute in the counter file; they are shown repo-relative above for
readability. The counter therefore recorded **2 production and 2 test files** against caps of 3 and
3 — exactly the Batch B set the plan's change-budget section declares, and within both caps at the
moment of the reset.

## True Counted-Write Count for Batch B

The counter's two production entries and two test entries are one entry per distinct file path, not
one per write. Batch B applied more than one edit to several of those files:

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — seven edits (P3-T1 through
  P3-T6, plus the line-budget compression),
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` — three edits (P3-T8, P3-T9,
  P3-T10),
- the Claude mode-resolution suite — eight edits (the P3-T12 through P3-T17 additions plus six
  comment compressions taken to bring the file back under the 500-line cap),
- the Codex mode-resolution suite — one write (P3-T18 and P3-T19 authored together).

The hook deduplicates by path, so the cap is a distinct-file cap and Batch B never approached it.
No scripted byte-copy was used in this phase, so the counter under-recording condition the plan
warns about — a copy bypassing the `Write|Edit` matcher — does not apply to Batch B. It becomes
relevant at Phase 4, where the four mirror copies are byte-copies.

The reset is the mechanism the hook's own block reason prescribes. `.claude/state/` is gitignored,
never appears in a diff, and is unrelated to the issue #510 condition.
