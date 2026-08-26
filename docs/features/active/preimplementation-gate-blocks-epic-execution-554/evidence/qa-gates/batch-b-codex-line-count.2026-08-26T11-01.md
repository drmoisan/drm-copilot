# Batch B — Codex Main Gate Hook Line Count (issue #554)

Timestamp: 2026-08-26T11-01

Command:

```powershell
(Get-Content -LiteralPath '.codex/hooks/enforce-orchestration-preimplementation-gate.ps1').Count
```

EXIT_CODE: 0

Output Summary:

| File | Lines | Cap | Headroom |
| --- | --- | --- | --- |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | **495** | 500 | **5** |

The file is at 495 lines, an integer at or below the 500-line cap in
`.claude/rules/general-code-change.md`. The Phase 0 baseline recorded 382 lines, so the Batch B
edits added 113 lines net — five more than the Claude surface, because the Codex classifier carries
an additional comment recording that its local `Get-StringProperty` trims where the Claude-side
reader does not, and why every marker test introduced here is therefore insensitive to that
divergence.

The count was taken **after** `mcp__drm-copilot__run_poshqc_format` ran, so it is the formatted
count and not a pre-format estimate. The formatter reformatted no file in that pass.

## Recorded Condition: Five Lines of Headroom

Five lines is the thinnest headroom of any file this change touches. It is recorded here rather
than left implicit because the four bundled mirrors are byte-copies of these two files, so any
later edit that pushes this file past 500 also pushes its mirror past 500, and
`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` asserts the 500-line bound
against BOTH the root and the bundled copy of every name in its static-check list.
