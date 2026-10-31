# Pester shard balance (P9-T4)

| Run | Shard 1 | Shard 2 | Shard 3 | Longest | Spread (longest - shortest) |
|---|---|---|---|---|---|
| Baseline, main run 41209645365 | 639 s | 268 s | 381 s | 639 s | 371 s |
| Branch head, run 41243409383 | 417 s | 497 s | 372 s | 497 s | 125 s |

- The spread fell from 371 s to 125 s (66% smaller). The longest shard fell from 639 s to 497 s (142 s, 22%).
- Decision: the spread is smaller, so no fourth shard is added. The `_poshqc.yml` matrix, the brief and `PoshQcWorkflow.Tests.ps1` are unchanged.
- Shard 2 is now the longest. The weights file was generated from one earlier CI run, so a later refresh from this run's JUnit artifacts may narrow the spread further. That is a refinement, not a requirement of this item.
- `PowerShell hook suites (Linux)`: 377 s baseline, 351 s now. `PowerShell QC static`: 212 s baseline, 220 s now.
