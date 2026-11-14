# QA Gate: Per-File Coverage and Baseline Comparison

Timestamp: 2026-11-07T15-18
Command: pwsh -File SCRATCH/issue-1096-thresholds.ps1 (reads the merged powershell-coverage.xml of the P6-T2 run and the JSON report of the P6-T3 run, both copied under SCRATCH/final/; derives the changed .ps1/.psm1/.py files outside tests/ from the merge base of origin/main and HEAD with git status --porcelain as companion; reads BASELINE-COVERAGE and BASELINE-FAILURE rows from the lexicographically greatest evidence/baseline/pester-parallel.*.md and pytest-parallel.*.md and GATE-FAILURE rows from the greatest evidence/qa-gates/ artifacts of the same gates; exits 1 unless every condition holds)
EXIT_CODE: 0
Output Summary: Every listed PowerShell file is at or above 85% line coverage and every listed Python file at or above 85% line and 75% branch coverage. Every COVERAGE-DELTA row is PASS or NEW (ratios compared unrounded). No changed file that a final report measures is missing from the list; the three bundle copies under extensions/drm-copilot/resources/powershell/PoshQC/ are measured by neither report and take no row. NEW-FAILURE: NONE.

## Step Output

LIST-UNMEASURED: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.LeakAllowlist.psm1 (no row)
LIST-UNMEASURED: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.LeakScan.psm1 (no row)
LIST-UNMEASURED: extensions/drm-copilot/resources/powershell/PoshQC/PoshQC.psm1 (no row)
BASELINE-SOURCES: pester-parallel.2026-11-07T14-21.md, pytest-parallel.2026-11-07T14-21.md
THRESHOLD: scripts/powershell/PoshQC/PoshQC.LeakScan.psm1 | line 221/225 98.22% | PASS
COVERAGE-DELTA: scripts/powershell/PoshQC/PoshQC.LeakScan.psm1 | NEW | line 221/225 | NEW
THRESHOLD: scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1 | line 83/87 95.40% | PASS
COVERAGE-DELTA: scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1 | NEW | line 83/87 | NEW
THRESHOLD: scripts/powershell/PoshQC/PoshQC.psm1 | line 54/61 88.52% | PASS
COVERAGE-DELTA: scripts/powershell/PoshQC/PoshQC.psm1 | line 54/61 | line 54/61 | PASS
THRESHOLD: scripts/dev-tools/DrmCopilotPromptSupport.ps1 | line 35/40 87.50% | PASS
COVERAGE-DELTA: scripts/dev-tools/DrmCopilotPromptSupport.ps1 | line 33/38 | line 35/40 | PASS
THRESHOLD: scripts/dev_tools/fix_all_branches.py | line 87/87 100.00% | branch 26/26 100.00% | PASS
COVERAGE-DELTA: scripts/dev_tools/fix_all_branches.py | line 82/82, branch 24/24 | line 87/87, branch 26/26 | PASS
THRESHOLD: scripts/dev_tools/fix_all_branches_extra.py | line 85/85 100.00% | branch 24/24 100.00% | PASS
COVERAGE-DELTA: scripts/dev_tools/fix_all_branches_extra.py | line 85/85, branch 24/24 | line 85/85, branch 24/24 | PASS
THRESHOLD: scripts/dev_tools/atomic_executor/cli_preflight.py | line 153/153 100.00% | branch 77/78 98.72% | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/cli_preflight.py | line 99/153, branch 36/78 | line 153/153, branch 77/78 | PASS
THRESHOLD: scripts/dev_tools/atomic_executor/qc_runner.py | line 96/103 93.20% | branch 14/18 77.78% | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/qc_runner.py | line 96/103, branch 14/18 | line 96/103, branch 14/18 | PASS
THRESHOLD: scripts/dev_tools/atomic_executor/prompt_builder.py | line 124/124 100.00% | branch 44/44 100.00% | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/prompt_builder.py | line 92/124, branch 26/44 | line 124/124, branch 44/44 | PASS
THRESHOLD: scripts/dev_tools/atomic_executor/qc_toolchain.py | line 15/15 100.00% | branch 0/0 n/a | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/qc_toolchain.py | line 15/15, branch 0/0 | line 15/15, branch 0/0 | PASS
FAILURE-SOURCES: pester-parallel | pester-parallel.2026-11-07T14-21.md | pester-parallel.2026-11-07T15-12.md | baseline 0 | final 0
FAILURE-SOURCES: pytest-parallel | pytest-parallel.2026-11-07T14-21.md | pytest-parallel.2026-11-07T15-16.md | baseline 0 | final 0
NEW-FAILURE: NONE
RESULT=PASS
