# QA Gate: Coverage Thresholds and AC-34 / AC-35 Comparisons (Remediation Cycle 1)

Timestamp: 2026-11-07T17-09
Command: sh SCRATCH/issue-1096-c1-thresholds.sh (pwsh SCRATCH/issue-1096-thresholds.ps1 reads the merged artifacts/pester/powershell-coverage.xml of the P3-T2 run, copied to SCRATCH/c1final/pester/, and the P3-T3 JSON report SCRATCH/c1final/issue-1096-coverage-c1final.json; it lists the changed .ps1, .psm1, and .py files outside tests/ from the merge base of origin/main and HEAD, compares each listed file with the BASELINE-COVERAGE rows of the latest evidence/baseline/pester-parallel.*.md and pytest-parallel.*.md, compares the GATE-FAILURE keys of the latest qa-gates artifacts with the BASELINE-FAILURE keys, and exits 1 on any shortfall)
EXIT_CODE: 0
Output Summary: Remediation cycle 1. Every PowerShell file is at or above 85% line coverage; every Python file is at or above 85% line and 75% branch coverage; every COVERAGE-DELTA row is PASS or NEW; NEW-FAILURE: NONE. RESULT=PASS.

## Sources

- Baseline: `pester-parallel.2026-11-07T14-21.md`, `pytest-parallel.2026-11-07T14-21.md` (recorded before any change)
- Final: `pester-parallel.2026-11-07T17-04.md`, `pytest-parallel.2026-11-07T17-08.md`

## List Check

The three bundle copies under `extensions/drm-copilot/resources/powershell/PoshQC/` (`PoshQC.LeakAllowlist.psm1`, `PoshQC.LeakScan.psm1`, `PoshQC.psm1`) are changed and have no coverage row; they are byte-identical mirrors of the measured repository-root modules, checked by `test_poshqc_bundled_module_files_match_repo_root_sources`. No measured changed file is missing from the list.

## Per-File Thresholds (spec AC-34)

| File | Line | Branch | Result |
|---|---|---|---|
| scripts/powershell/PoshQC/PoshQC.LeakScan.psm1 | 221/225 (98.22%) | n/a (Pester) | PASS |
| scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1 | 86/90 (95.56%) | n/a (Pester) | PASS |
| scripts/powershell/PoshQC/PoshQC.psm1 | 54/61 (88.52%) | n/a (Pester) | PASS |
| scripts/dev-tools/DrmCopilotPromptSupport.ps1 | 35/40 (87.50%) | n/a (Pester) | PASS |
| scripts/dev_tools/fix_all_branches.py | 87/87 (100.00%) | 26/26 (100.00%) | PASS |
| scripts/dev_tools/fix_all_branches_extra.py | 85/85 (100.00%) | 24/24 (100.00%) | PASS |
| scripts/dev_tools/atomic_executor/cli_preflight.py | 153/153 (100.00%) | 77/78 (98.72%) | PASS |
| scripts/dev_tools/atomic_executor/qc_runner.py | 96/103 (93.20%) | 14/18 (77.78%) | PASS |
| scripts/dev_tools/atomic_executor/prompt_builder.py | 124/124 (100.00%) | 44/44 (100.00%) | PASS |
| scripts/dev_tools/atomic_executor/qc_toolchain.py | 15/15 (100.00%) | 0/0 (n/a) | PASS |

## Coverage Delta Against the Baseline (spec AC-34)

COVERAGE-DELTA: scripts/powershell/PoshQC/PoshQC.LeakScan.psm1 | NEW | line 221/225 | NEW
COVERAGE-DELTA: scripts/powershell/PoshQC/PoshQC.LeakAllowlist.psm1 | NEW | line 86/90 | NEW
COVERAGE-DELTA: scripts/powershell/PoshQC/PoshQC.psm1 | line 54/61 | line 54/61 | PASS
COVERAGE-DELTA: scripts/dev-tools/DrmCopilotPromptSupport.ps1 | line 33/38 | line 35/40 | PASS
COVERAGE-DELTA: scripts/dev_tools/fix_all_branches.py | line 82/82, branch 24/24 | line 87/87, branch 26/26 | PASS
COVERAGE-DELTA: scripts/dev_tools/fix_all_branches_extra.py | line 85/85, branch 24/24 | line 85/85, branch 24/24 | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/cli_preflight.py | line 99/153, branch 36/78 | line 153/153, branch 77/78 | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/qc_runner.py | line 96/103, branch 14/18 | line 96/103, branch 14/18 | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/prompt_builder.py | line 92/124, branch 26/44 | line 124/124, branch 44/44 | PASS
COVERAGE-DELTA: scripts/dev_tools/atomic_executor/qc_toolchain.py | line 15/15, branch 0/0 | line 15/15, branch 0/0 | PASS

## No New Failure (spec AC-35)

- pester-parallel: baseline 0 failure keys, final 0 failure keys
- pytest-parallel: baseline 0 failure keys, final 0 failure keys

NEW-FAILURE: NONE
