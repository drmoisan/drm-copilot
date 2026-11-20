# New and Changed Code Coverage, Run A (P6-T13)

Timestamp: 2026-10-02T08-45
Command: CI-evidence deviation DEV-P6-CL (replaces CL args '.', 'artifacts/pester/final-run-a-coverage.xml', $base, <file>). `poetry -C <ROOT> run python <ROOT>/artifacts/ci/ci_evidence.py cl <ROOT>/artifacts/ci/run-36983551836/powershell-coverage.xml 589b51a30d856dca973a2ed9988f9443c35339cf scripts/powershell/PoshQC/PoshQC.Testing.psm1` and the same with `scripts/powershell/PoshQC/PoshQC.psm1` (Python port of rule CL; the added lines come from `git diff -U0 589b51a30d856dca973a2ed9988f9443c35339cf -- <file>` against the worktree, whose code tree equals a987ebfb, the SHA run A measured). Executor re-ran both this segment; output identical to the orchestrator's `cl-testing.txt` and `cl-psm1.txt`. Coverage XML from run A https://github.com/drmoisan/drm-copilot/actions/runs/36983551836 (job https://github.com/drmoisan/drm-copilot/actions/runs/36983551836/job/110763341194). `PoshQC.Coverage.psm1` KEY row from P6-T5.
EXIT_CODE: 0
Output Summary: PoshQC.Coverage.psm1 104/109 = 95.41%; PoshQC.Testing.psm1 changed lines CHANGED_EXECUTABLE=11 CHANGED_COVERED=11 CHANGED_PCT=100.00; PoshQC.psm1 changed lines CHANGED_EXECUTABLE=0 CHANGED_PCT=NA.
- Acceptance (AC-14): PoshQC.Coverage.psm1 at least 85.00 (95.41, met); each CL run prints CHANGED_PCT at least 85.00 (Testing 100.00, met) or CHANGED_PCT=NA with CHANGED_EXECUTABLE=0 (PoshQC.psm1: the one added line is the sub-module list entry `'PoshQC.Coverage.psm1',`, which is not an executable `<line>` element; met).

## KEY row (run A CX)

```text
KEY scripts/powershell/PoshQC|PoshQC.Coverage.psm1 missed=5 covered=104
```

## CL output

```text
# scripts/powershell/PoshQC/PoshQC.Testing.psm1
ADDED_LINES=25 CHANGED_EXECUTABLE=11 CHANGED_COVERED=11
CHANGED_PCT=100.00
UNCOVERED_CHANGED_LINES=
# scripts/powershell/PoshQC/PoshQC.psm1
ADDED_LINES=1 CHANGED_EXECUTABLE=0 CHANGED_COVERED=0
CHANGED_PCT=NA
UNCOVERED_CHANGED_LINES=
```
