# QA Gate: Coverage Thresholds and AC-34 / AC-35 Comparisons (Remediation Cycle 2, Phase 2 restart)

Timestamp: 2026-11-07T18-31
Command: sh SCRATCH/issue-1096-c2r-thresholds.sh (pwsh SCRATCH/issue-1096-thresholds.ps1 reads the merged artifacts/pester/powershell-coverage.xml of the restart P2-T2 run, copied to SCRATCH/c2r/pester/, and the restart P2-T3 JSON report SCRATCH/c2r/issue-1096-coverage-c2r.json; it checks the changed-file list against the diff from the merge base of origin/main and HEAD, reads the BASELINE-COVERAGE and BASELINE-FAILURE rows of the lexicographically greatest evidence/baseline/pester-parallel.*.md and pytest-parallel.*.md, and the GATE-FAILURE rows of the lexicographically greatest evidence/qa-gates/ artifacts; exits 1 unless every condition holds)
EXIT_CODE: 0
Output Summary: Phase 2 restart after the orchestrator's conflict-free merge of origin/main (PR #1113, issue #1105). Every PowerShell file is at or above 85% line coverage; every Python file is at or above 85% line and 75% branch coverage; every COVERAGE-DELTA row is PASS or NEW; NEW-FAILURE: NONE. RESULT=PASS.

## Sources

- Baseline (Decision 9 record, this item's `Phase 0 baseline`): `pester-parallel.2026-11-07T14-21.md`, `pytest-parallel.2026-11-07T14-21.md`
- Final: `pester-parallel.2026-11-07T18-26.md`, `pytest-parallel.2026-11-07T18-30.md`

## List Check

The three bundle copies under `extensions/drm-copilot/resources/powershell/PoshQC/` (`PoshQC.LeakAllowlist.psm1`, `PoshQC.LeakScan.psm1`, `PoshQC.psm1`) are changed and have no coverage row; they are byte-identical mirrors of the measured repository-root modules (`test_poshqc_bundled_module_files_match_repo_root_sources` passed in the restart P2-T3). No measured changed file is missing from the list. The PR #1113 merge adds no file to the diff from the merge base, because every file it brought is already on `origin/main`.

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

Tests that `main` added through PR #1110 and PR #1113 have no baseline key; none of them failed in the final runs.

NEW-FAILURE: NONE
