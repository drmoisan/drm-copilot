# Batch B — Claude Main Gate Hook Line Count (issue #554)

Timestamp: 2026-08-26T11-01

Command:

```powershell
(Get-Content -LiteralPath '.claude/hooks/enforce-orchestration-preimplementation-gate.ps1').Count
```

EXIT_CODE: 0

Output Summary:

| File | Lines | Cap | Headroom |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | **490** | 500 | **10** |

The file is at 490 lines, an integer at or below the 500-line cap in
`.claude/rules/general-code-change.md`. The Phase 0 baseline recorded 382 lines, so the Batch B
edits added 108 lines net.

## Note on an Intermediate Breach and How It Was Removed

The first draft of the Batch B edits measured **520 lines**, which breached the cap by 20. The
breach was removed by compressing comment volume and one control-flow block, with no behavioural
change and no deleted logic:

1. The two per-mode read seams (`Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent`) were
   given one shared leading comment instead of two comment-based help blocks, which also makes them
   mirror the shape of the pre-existing `Get-CheckpointContent` more exactly.
2. `Get-OrchestrationModeDenyReason` and the replaced `Test-ImplementationDelegation` carry leading
   `#` comments instead of comment-based help blocks. `.claude/rules/powershell.md` states no
   comment-based-help requirement, so the content is preserved in a denser form.
3. The epic/parallel dispatch branch selects its injected parameter name once and indexes
   `$PSBoundParameters` with it, instead of repeating the whole `ContainsKey`-and-seam decision for
   each of the two modes. The `ContainsKey` decision itself is unchanged: it is never a truthiness
   test, so an explicitly bound empty string still suppresses the read seam.

Behaviour was re-verified after the compression: an epic-mode delegation with a ready injected
checkpoint allows, the same delegation with `-EpicCheckpointRaw` bound to the empty string denies,
and a delegation declaring a non-canonical `epic_checkpoint_path` denies with the
`declared-checkpoint-path` predicate named in its reason.
