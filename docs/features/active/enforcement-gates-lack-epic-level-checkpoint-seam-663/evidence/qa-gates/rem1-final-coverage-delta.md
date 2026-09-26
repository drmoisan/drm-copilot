# Remediation Cycle 1 PowerShell Coverage Delta ([P4-T5])

Timestamp: 2026-09-25T21-36
Command: sh <SCRATCHPAD>/rem1/runout.sh p4-delta  (reads artifacts/pester/powershell-coverage.xml; git diff -U0 77da1f86 -- <three files>; git diff -U0 origin/main -- <three files>)
EXIT_CODE: 0
Output Summary: Post: helpers 97.04% (both copies, missed 5), EpicScopeResolution.psm1 90.38% (missed 10). Cycle changed-line coverage 100% for all three; branch changed-line coverage 100%, 100%, 90.38%. No regression against [P0-T10] or the recorded values.

Pass: 1

Sources: [P0-T10] `evidence/remediation-baseline/rem1-pester-coverage.md`; recorded `evidence/qa-gates/final-pester-coverage.md` (RR-2); post [P4-T4] `evidence/qa-gates/rem1-final-pester-coverage.md` (same `artifacts/pester/powershell-coverage.xml`, last write 2026-09-26T01:34:34Z). Changed-line rule (main-plan section 5): added line numbers from `git diff -U0 <anchor> -- <file>` that carry a `line` element count as covered when `ci` is greater than 0; added lines without a `line` element are outside the denominator.

| File | [P0-T10] percent / missed | Recorded percent / missed | Post percent / missed | Cycle changed-line (77da1f86) | Branch changed-line (origin/main) |
| --- | --- | --- | --- | --- | --- |
| .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% / 5 | 96.97% / 5 | 97.04% / 5 | 100.00% (4 of 4 executable added lines) | 100.00% (19 of 19) |
| .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 | 96.97% / 5 | 96.97% / 5 | 97.04% / 5 | 100.00% (4 of 4) | 100.00% (19 of 19) |
| .claude/lib/worktree-resolution/EpicScopeResolution.psm1 | 90.38% / 10 | 90.38% / 10 | 90.38% / 10 | 100.00% (1 of 1) | 90.38% (94 of 104; the file is new on the branch) |

Threshold and no-regression checks:

- Every post percent is at least 85%: yes (97.04%, 97.04%, 90.38%).
- Every cycle and branch changed-line figure is at least 85%: yes (lowest 90.38%).
- Against [P0-T10] and against the recorded values, post percent is at least the baseline percent or post missed is at most the baseline missed: helpers 97.04% >= 96.97% (and missed 5 <= 5), both copies; module 90.38% >= 90.38% (and missed 10 <= 10).
- The report carries `line` elements (AnyLineElements: True), so the task is not remediation-required.

Result: PASS.

## Output

```
CoverageLastWriteUtc: 2026-09-26T01:34:34.7876544Z
.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: post 97.04% covered=164 missed=5
  cycle (git diff -U0 77da1f86): addedLines=18 executableAdded=4 coveredAdded=4 changedLineCoverage=100.00% uncoveredAddedLines=none
  branch (git diff -U0 origin/main): addedLines=63 executableAdded=19 coveredAdded=19 changedLineCoverage=100.00% uncoveredAddedLines=none
.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1: post 97.04% covered=164 missed=5
  cycle (git diff -U0 77da1f86): addedLines=18 executableAdded=4 coveredAdded=4 changedLineCoverage=100.00% uncoveredAddedLines=none
  branch (git diff -U0 origin/main): addedLines=63 executableAdded=19 coveredAdded=19 changedLineCoverage=100.00% uncoveredAddedLines=none
.claude/lib/worktree-resolution/EpicScopeResolution.psm1: post 90.38% covered=94 missed=10
  cycle (git diff -U0 77da1f86): addedLines=10 executableAdded=1 coveredAdded=1 changedLineCoverage=100.00% uncoveredAddedLines=none
  branch (git diff -U0 origin/main): addedLines=369 executableAdded=104 coveredAdded=94 changedLineCoverage=90.38% uncoveredAddedLines=63,78,137,170,197,210,236,245,305,347
AnyLineElements: True
PROCESS_EXIT_CODE: 0
```
