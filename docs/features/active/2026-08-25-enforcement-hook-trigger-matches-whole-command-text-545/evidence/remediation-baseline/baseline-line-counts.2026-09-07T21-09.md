# Baseline — Pre-Edit Line-Count Inventory (cycle 2)

Timestamp: 2026-09-07T21-09
Task: [P0-T11]
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

Command: wc -l .claude/hooks/hook-command-scanner.ps1 .codex/hooks/hook-command-scanner.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-parallel-abandon-gate.ps1 .claude/hooks/enforce-pr-author-skill-helpers.ps1 .claude/hooks/validate-bash.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
EXIT_CODE: 0

## Observed output

```
   450 .claude/hooks/hook-command-scanner.ps1
   450 .codex/hooks/hook-command-scanner.ps1
   472 .claude/hooks/enforce-epic-merge-gate.ps1
   174 .codex/hooks/enforce-epic-merge-gate.ps1
   331 .claude/hooks/enforce-parallel-abandon-gate.ps1
   240 .claude/hooks/enforce-pr-author-skill-helpers.ps1
   420 .claude/hooks/validate-bash.ps1
   500 .codex/hooks/enforce-orchestration-preimplementation-gate.ps1
  3037 total
```

All eight counts are recorded.

## Comparison against standing constraint 4

| File | Constraint 4 value | Observed | Match | Headroom to 500 |
|---|---|---|---|---|
| `.claude/hooks/hook-command-scanner.ps1` | 450 | **450** | yes | 50 |
| `.codex/hooks/hook-command-scanner.ps1` | 450 | **450** | yes | 50 |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 472 | **472** | yes | 28 |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | 174 | **174** | yes | 326 |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 331 | **331** | yes | 169 |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 240 | **240** | yes | 260 |
| `.claude/hooks/validate-bash.ps1` | 420 | **420** | yes | 80 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 500 (required) | **500** | yes | **0** |

**Zero divergence.** Every one of the seven files this cycle edits equals its constraint-4 value,
and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` reads exactly 500. The tree is
the tree this plan was authored against, so the `BLOCKED` branch of this task was not taken.

## The missing-trailing-newline observation, re-derived

Constraint 4 records that `.claude/hooks/enforce-epic-merge-gate.ps1` has no trailing newline, so
`wc -l` reports 472 while the file carries 473 lines of content. Confirmed directly:

```
$ tail -c 1 .claude/hooks/enforce-epic-merge-gate.ps1 | od -c
0000000   )
0000001
```

The final byte is `)`, not `\n`. The file therefore carries 473 lines of content against a `wc -l`
reading of 472, and its headroom is 28 lines by `wc -l` and 27 lines of content.

## Line-cap risk assessment for this cycle's edits

| File | Edit | Lines added | Post-edit `wc -l` (projected) | At or under 500 |
|---|---|---|---|---|
| `.claude/hooks/hook-command-scanner.ps1` | Edit 1 | ~34 | ~484 | yes |
| `.codex/hooks/hook-command-scanner.ps1` | Edit 1 | ~34 | ~484 | yes |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | Edit 2 | 14 | **486** | yes |
| `.codex/hooks/enforce-epic-merge-gate.ps1` | Edit 3 | ~12 | ~186 | yes |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | Edit 4 | ~20 | ~351 | yes |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | Edit 5 | ~14 | ~254 | yes |
| `.claude/hooks/validate-bash.ps1` | Edit 6 | ~15 | ~435 | yes |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | **none** | 0 | 500 | yes |

The two tightest are the scanner pair, at 50 lines of headroom each, and the Claude merge gate, at
28 lines by `wc -l` and 27 lines of content against an Edit 2 that adds 14. Where an edit would
exceed 500, the remedy stated by constraint 4 is to shorten the added comment prose; the
comment-based help block must not be deleted and no code line may be dropped.

`.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` sits at exactly the cap with zero
headroom. R-2 does not touch it and no task in this plan may. Its count is recorded here so a later
gate can confirm it is still 500.

## Output Summary

All eight `wc -l` counts recorded and every one matches standing constraint 4 exactly, including the
required 500 for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`. Zero divergence,
so execution proceeds rather than blocking. The missing trailing newline on
`.claude/hooks/enforce-epic-merge-gate.ps1` was independently confirmed by `tail -c 1`, which
returns `)`. Every projected post-edit count stays at or under the 500-line cap.
