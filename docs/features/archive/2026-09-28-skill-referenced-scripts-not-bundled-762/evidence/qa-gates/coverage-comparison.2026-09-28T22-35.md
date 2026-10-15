# Coverage Comparison (P10-T7)

Timestamp: 2026-09-28T22-35
Command: compiled from the artifacts of P0-T14, P0-T17, P0-T19, P8-T3, P9-T4, P9-T5, P10-T5, P10-T6 (no new command)
EXIT_CODE: 0
Output Summary: Every coverage threshold of P8-T3, P9-T4, P9-T5, P10-T5, and P10-T6 holds, with no regression in any language. Disposition: PASS (coverage). This disposition covers coverage only. The separate CI-run conclusion failure (P10-T3, npm audit) is recorded in `ci-dispatch.2026-09-28T22-17.md`.

## bash (kcov, line coverage only; CI canonical)

Baseline Coverage: 93.3% total lines (CI run 36494352285, main 5d0b93a0); shell_qc_lib.sh 0.865; the ten cleanup scripts at `scripts/bash/`: 0.976, 0.953, 1.000, 0.942, 0.924, 0.954, 0.870, 0.906, 0.890, 0.875
Post-Change Coverage: 93.3% total lines (CI run 36513322997, FINAL_SHA 670577f2); shell_qc_lib.sh 0.865; the ten scripts at `.claude/skills/cleanup-merged-worktrees/scripts/`: 0.976, 0.953, 1.000, 0.942, 0.924, 0.954, 0.870, 0.906, 0.890, 0.875
New/Changed-code Coverage: shell_qc_lib.sh (changed) 86.5% line; relocated scripts 87.0% to 100.0% line each, all measured under the new path; every file is at or above 85%
Disposition: PASS (total 93.3 >= 85.0 and >= baseline 93.3; no per-file rate lower than baseline)

## PowerShell (Pester, line coverage only)

Baseline Coverage: scripts/orchestration/Invoke-CiGateParser.ps1 LinePercent=94.12 (34 analyzed, 32 covered)
Post-Change Coverage: .claude/lib/ci-gate/Invoke-CiGateParser.ps1 LinePercent=94.12 (34 analyzed, 32 covered)
New/Changed-code Coverage: 94.12% line (relocated parser; only its `.EXAMPLE` help text changed)
Disposition: PASS (94.12 >= 85 and >= baseline 94.12)

## Python (pytest-cov, scripts.dev_tools)

Baseline Coverage: TOTAL LinePercent=93.08 BranchPercent=85.86
Post-Change Coverage: TOTAL LinePercent=93.11 BranchPercent=85.92
New/Changed-code Coverage: scripts/dev_tools/skill_bundle_contract.py LinePercent=96.45 BranchPercent=95.00; scripts/dev_tools/skill_bundle_contract_cli.py LinePercent=92.98 BranchPercent=77.27
Disposition: PASS (total and both new modules meet line >= 85 and branch >= 75; the total did not regress)
