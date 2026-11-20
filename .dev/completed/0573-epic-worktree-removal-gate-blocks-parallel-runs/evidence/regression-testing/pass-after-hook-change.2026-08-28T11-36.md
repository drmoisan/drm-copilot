# Pass-After — Full Suite for the Changed Hook (P2-T5)

Timestamp: 2026-08-28T11-36

Task: [P2-T5]
Issue: #573
Acceptance criteria discharged (green): AC-1 through AC-10
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `pwsh -NoProfile -Command "if ((Invoke-Pester -Path tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1 -Output Detailed -PassThru).FailedCount -gt 0) { exit 1 } else { exit 0 }"`

EXIT_CODE: 0

## Counts read from the `Tests Passed: N, Failed: M` summary line

```
Tests Passed: 46, Failed: 0, Skipped: 0, Inconclusive: 0, NotRun: 0
```

| Metric | Value | Required |
| --- | --- | --- |
| Failed | 0 | 0 |
| Passed | 46 | pre-existing 27 (from [P0-T4]) + 19 = 46 |

Both figures are transcribed from that summary line. `27 + 19 = 46`, so the passed count is exactly the pre-existing baseline plus the 19 new tests, and no pre-existing test was lost or duplicated.

## The 19 new tests, each traced to its acceptance criterion

Every test below was observed on its own `[+]` per-test line of the `-Output Detailed` output.

### AC-1, AC-2, AC-3 — `Context parallel branch allow (AC-1, AC-2, AC-3)`

1. `allows when the matching parallel items[] record has merge_status merged` — **AC-1**
2. `allows when the matching parallel items[] record has merge_status worktree_removed` — **AC-2**
3. `matches a parallel worktree_path across backslash/forward-slash separator differences` — **AC-3**

### AC-4 — `Context parallel branch fail-closed deny (AC-4)`

4. `denies when both checkpoint seams return $null`
5. `denies when the parallel checkpoint body is malformed JSON`
6. `denies when route_id is absent even though a merged matching item is present`
7. `denies when route_id is present but is not parallel even though a merged matching item is present`
8. `denies when route_id is parallel but no items key exists`
9. `denies when no items[] entry matches the target worktree path`
10. `denies when the matched parallel item has merge_status pr_open`
11. `denies when the matched parallel item carries no merge_status key`

Cases 4 through 10 are the seven fail-closed deny cases AC-4 enumerates; case 11 is the additional eighth case the task requires.

### AC-7 and AC-5 — `Context branch precedence and check ordering (AC-5, AC-7)`

12. `allows when the epic checkpoint authorizes while the parallel checkpoint does not (branches are ORed)` — **AC-7**
13. `emits the envelope-anomaly deny before reading either checkpoint` — **AC-5**, with `Should -Invoke -Times 0 -Exactly` asserted on both seams

### AC-8 — `Context Test-ParallelCheckpointAllowsWorktreeRemoval direct branch coverage (AC-8)`

14. `returns $false when Checkpoint is $null`
15. `returns $false when the route_id key is absent`
16. `returns $false when the items key is absent`
17. `skips an items[] entry that carries no worktree_path key`

### AC-9 — `Context real Test-Path parallel read seam (AC-9)`

18. `Get-EpicWorktreeGateParallelCheckpointContent returns $null when the checkpoint file does not exist`
19. `Get-EpicWorktreeGateParallelCheckpointContent reads real content when the file exists`

### AC-6 — pre-existing epic-branch behavior unchanged

All 27 pre-existing tests still pass, including the three epic allow tests (`merged`, `worktree_removed`, separator normalization) and the four epic deny tests. Branch 1 was rewired only to obtain its parsed checkpoint through `ConvertFrom-EpicWorktreeGateJson` instead of the inline `try`/`catch`; its decisions are unchanged, as the unchanged pass set demonstrates.

### AC-10 — determinism mocks

Discharged by [P2-T4] and re-verified here: a fixed-string search reports the parallel-seam `$null` mock at 9 lines of the suite, of which 7 sit outside the new parallel contexts (lines 32, 49, 81, 90, 103, 116, 189) — the four checkpoint-reading deny tests, the two envelope-anomaly deny tests, and the entry-point `BeforeEach`. The file docstring carries the determinism statement naming both read seams.

## File sizes

- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`: 418 lines (limit 500).
- `tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.Tests.ps1`: 428 lines (limit 500).

No eighth file was created.

Output Summary: GREEN. `Tests Passed: 46, Failed: 0`; wrapper exit 0. The passed count equals the [P0-T4] pre-existing in-scope count of 27 plus the 19 new tests. All 19 new tests are named above and each is traced to the acceptance criterion it discharges, covering AC-1 through AC-9; AC-6 is carried by the unchanged 27 pre-existing passes and AC-10 by the 7 out-of-context parallel-seam mocks plus the docstring rule. Hook is 418 lines and the suite 428 lines, both under the 500-line limit.
