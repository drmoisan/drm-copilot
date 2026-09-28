# Batch A — 500-Line Cap Verification for the Two New Modes Files (issue #554)

Timestamp: 2026-08-26T10-45

Command:

```powershell
foreach ($p in '.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1',
               '.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1') {
  '{0}  Lines={1}' -f $p, (Get-Content -LiteralPath $p).Count
}
```

EXIT_CODE: 0

Output Summary:

| File | Lines | Cap | Headroom | Verdict |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | **477** | 500 | 23 | at or below cap |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | **477** | 500 | 23 | at or below cap |

Both recorded counts are integers at or below 500.

## Note on How the Count Was Reached

The first draft of the Claude modes file came in at 632 lines and the second at 548, both over the
500-line cap in `.claude/rules/general-code-change.md`. The file was reduced to 477 by condensing the
comment-based help blocks and by removing the redundant `.OUTPUTS` sections, whose content is already
declared by each function's `[OutputType()]` attribute. No behaviour was removed and no normative
statement was dropped: the purity declaration, the never-parse-a-path-from-the-prompt statement, the
trailing-period asymmetry rationale, the decision D3 issue-number widening note, the decision D7
`epic_manifest_path` tightening rationale, and the decision D8 merge-status rule all remain in the
file. A duplicated property-reader body was also factored into the single seam
`Get-OrchestrationModeProperty`, which both `Get-OrchestrationModeString` and
`Get-OrchestrationModeCollection` now call.

The Codex file is one character shorter than the Claude file (19534 versus 19535 characters) because
the two differ in exactly one line, the header's surface reference. A line-by-line comparison reports
exactly two differing lines, which are the two halves of that single substitution.
