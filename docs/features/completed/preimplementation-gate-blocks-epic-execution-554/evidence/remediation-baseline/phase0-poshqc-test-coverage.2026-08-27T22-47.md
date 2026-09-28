# Phase 0 — PowerShell Test and Coverage Baseline (remediation cycle 1)

Timestamp: 2026-08-27T23-55
Cycle Timestamp: 2026-08-27T22-47
Task: [P0-T6]
Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -SettingsPath 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'"` run from the worktree root
EXIT_CODE: 0

## Pester result line

```text
Tests completed in 123s
Tests Passed: 3799, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 93.73% / 0%. 10,525 analyzed Commands in 88 Files.
```

| Metric | Value |
| --- | --- |
| Passed | **3799** |
| Failed | **0** |
| Skipped | 9 |
| Inconclusive | 0 |
| NotRun | 0 |

## Coverage counters at the report root of `artifacts/pester/powershell-coverage.xml`

Read directly from the JaCoCo-form report's top-level `counter` elements:

| Counter | Covered | Missed | Total | Percentage |
| --- | --- | --- | --- | --- |
| INSTRUCTION | 9865 | 660 | 10525 | 93.7292% |
| **LINE** | **7174** | **440** | **7614** | **94.2212%** |
| METHOD | 626 | 41 | 667 | 93.8531% |
| CLASS | 88 | 0 | 88 | 100.0000% |

**Repository-wide LINE coverage baseline: 94.2212%.**

The Pester console headline `Covered 93.73%` is the INSTRUCTION (command) figure and is deliberately
NOT recorded as the line figure, per `.claude/rules/powershell.md` line 64, which states that Pester
reports command (instruction) coverage and line coverage separately and that only the line threshold
is gated.

Pester measures no branch coverage in any output format, so no branch figure exists in the report and
none is recorded. `.claude/rules/general-unit-test.md` line 24 exempts PowerShell from the branch
threshold on exactly this basis.

## Reference for [P3-T4]

[P3-T4] requires the post-remediation passed count to exceed this baseline by at least 17 (ten cases
from Phase 1 plus seven from Phase 2). The target is therefore **at least 3816** passed with **0**
failed.

Output Summary: Baseline run exited 0 with **3799 passed, 0 failed**, 9 skipped. Repository-wide
LINE coverage is **94.2212%** (7174 covered of 7614), well above the 85% uniform threshold. The
94.22% figure reproduces the value independently recomputed by `policy-audit.2026-08-27T22-47.md`,
confirming the coverage report this remediation measures against is the same one the cycle-1 audit
read.
