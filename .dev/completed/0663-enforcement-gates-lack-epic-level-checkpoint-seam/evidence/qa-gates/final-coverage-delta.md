# PowerShell Coverage Delta ([P8-T8])

Pass: 2
Timestamp: 2026-09-25T20-12
Command: sh <SCRATCHPAD>/i663/run.sh p8-delta  (fresh PowerShell 7 process; reads artifacts/pester/powershell-coverage.xml from [P8-T7] pass 2 and, per file, the added line numbers from `git diff -U0 origin/main -- <file>`; an added line counts as covered when its `line` element has `ci` greater than 0; added lines without a `line` element are outside the denominator); baseline values from `evidence/baseline/p0-pester-coverage.md` ([P0-T10])
EXIT_CODE: 0
Output Summary: Every post percent is at least 85% (lowest 90.38%, EpicScopeResolution.psm1). Every changed-line figure is at least 85% (lowest 90.38%). Each of the six pre-existing files meets the pre-declared no-regression rule on both arms: post percent is at least the baseline percent and post `missed` is at most the baseline `missed`. The report carries `line` elements (AnyLineElements: True).

Coverage report last-write time: 2026-09-26T00:10:27Z (the [P8-T7] pass-2 run).

## Per-file delta

| File | Baseline % | Post % | Baseline missed | Post missed | Added lines | Executable added | Covered added | Changed-line coverage | No-regression rule |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.71% | 96.97% | 5 | 5 | 54 | 15 | 15 | 100.00% | met (percent up; missed equal) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.71% | 96.97% | 5 | 5 | 54 | 15 | 15 | 100.00% | met (percent up; missed equal) |
| .claude/hooks/enforce-pr-author-skill-helpers.ps1 | 96.67% | 97.00% | 3 | 3 | 28 | 13 | 13 | 100.00% | met (percent up; missed equal) |
| .claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1 | 92.31% | 93.55% | 2 | 2 | 19 | 5 | 5 | 100.00% | met (percent up; missed equal) |
| .claude/hooks/enforce-model-routing-receipt.ps1 | 94.74% | 95.52% | 3 | 3 | 20 | 10 | 10 | 100.00% | met (percent up; missed equal) |
| .claude/hooks/enforce-orchestration-preimplementation-gate.ps1 | 88.31% | 93.42% | 18 | 10 | 14 | 6 | 6 | 100.00% | met (percent up; missed down) |
| .claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 | n/a (new file) | 100.00% | n/a | 0 | 127 | 27 | 27 | 100.00% | n/a (new file) |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | n/a (new file) | 90.38% | n/a | 10 | 366 | 104 | 94 | 90.38% | n/a (new file) |
| .claude/lib/worktree-resolution/EpicScopeReadiness.psm1 | n/a (new file) | 95.92% | n/a | 2 | 176 | 49 | 47 | 95.92% | n/a (new file) |

Raw post counters (covered/missed): helpers 160/5 (both copies), pr-author helpers 97/3, epic-base-branch 29/2, model-routing 64/3, gate 142/10, epic-scope sibling 27/0, EpicScopeResolution 94/10, EpicScopeReadiness 47/2. Baseline raw counters (covered/missed): helpers 147/5 (both copies), pr-author helpers 87/3, epic-base-branch 24/2, model-routing 54/3, gate 136/18.

Uncovered added lines (informational): EpicScopeResolution.psm1 lines 62, 77, 136, 169, 196, 209, 235, 244, 304, 344; EpicScopeReadiness.psm1 lines 47, 106.

## Script output

```
CoverageLastWriteUtc: 2026-09-26T00:10:27.9483132Z
.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: addedLines=54 executableAdded=15 coveredAdded=15 changedLineCoverage=100.00% uncoveredAddedLines=none
.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: addedLines=54 executableAdded=15 coveredAdded=15 changedLineCoverage=100.00% uncoveredAddedLines=none
.claude/hooks/enforce-pr-author-skill-helpers.ps1: addedLines=28 executableAdded=13 coveredAdded=13 changedLineCoverage=100.00% uncoveredAddedLines=none
.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1: addedLines=19 executableAdded=5 coveredAdded=5 changedLineCoverage=100.00% uncoveredAddedLines=none
.claude/hooks/enforce-model-routing-receipt.ps1: addedLines=20 executableAdded=10 coveredAdded=10 changedLineCoverage=100.00% uncoveredAddedLines=none
.claude/hooks/enforce-orchestration-preimplementation-gate.ps1: addedLines=14 executableAdded=6 coveredAdded=6 changedLineCoverage=100.00% uncoveredAddedLines=none
.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1: addedLines=127 executableAdded=27 coveredAdded=27 changedLineCoverage=100.00% uncoveredAddedLines=none
.claude/lib/worktree-resolution/EpicScopeResolution.psm1: addedLines=366 executableAdded=104 coveredAdded=94 changedLineCoverage=90.38% uncoveredAddedLines=62,77,136,169,196,209,235,244,304,344
.claude/lib/worktree-resolution/EpicScopeReadiness.psm1: addedLines=176 executableAdded=49 coveredAdded=47 changedLineCoverage=95.92% uncoveredAddedLines=47,106
AnyLineElements: True
PROCESS_EXIT_CODE: 0
```

Result: PASS
