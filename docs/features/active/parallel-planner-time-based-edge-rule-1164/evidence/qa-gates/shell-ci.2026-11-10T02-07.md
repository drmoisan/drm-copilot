# Bash Final Gate from CI on the Branch (P6-T8)

Timestamp: 2026-11-10T02-07
Command: git push -u origin feature/parallel-planner-time-based-edge-rule-1164; gh workflow run ci.yml --ref feature/parallel-planner-time-based-edge-rule-1164; gh run view 42737591848 --json jobs; gh api repos/drmoisan/drm-copilot/actions/jobs/129570649419 (steps); gh api --allow-escape-sequences repos/drmoisan/drm-copilot/actions/jobs/129570649419/logs; gh run download 42737591848 -n shell-coverage -D SCRATCH/shell-final
EXIT_CODE: 0
Output Summary:
- Run: 42737591848 (ci.yml, event workflow_dispatch, head ref feature/parallel-planner-time-based-edge-rule-1164, head 31be4b9778049c83f1da6d4052694f92b8c19f6e); run conclusion success. URL: https://github.com/drmoisan/drm-copilot/actions/runs/42737591848
- shell-coverage / Shell Coverage (Bats + kcov) (job 129570649419): success.
- Run shell-qc check (shfmt diff + shellcheck) step: success, 0 findings (the step printed no diff and no shellcheck diagnostic; it fails on any finding). This is the bash final static record.
- Run shell-qc test with coverage step: success. Bats: plan 1..799; 799 ok, 0 not ok (Phase 0 baseline: 799 ok, 0 not ok).
- tests/shell/parallel_manifest_parity.bats: ok 154 "the manifest parity corpus meets the declared floor", ok 155 "python3 is available to read the corpus", ok 156 "the bash lane reproduces every manifest corpus fixture" (the M9 fixtures are in that corpus).
- kcov repo-wide line coverage (cov.xml): 3457 / 3644 = 94.9% (Phase 0 baseline 94.7%).
- kcov line coverage of .claude/lib/bash/parallel-manifest-validate.sh: 119 / 122 = 97.54% (line-rate 0.975; Phase 0 baseline 117 / 120 = 97.5%).
- kcov line coverage of .claude/lib/bash/parallel-manifest-pairs.sh (new): 68 / 68 = 100.00% (line-rate 1.000).
- CI Required Gate (job 129579794007): success. Every other job of the run concluded success, including poshqc / PowerShell QC, the three PowerShell QC shards, PowerShell QC static, PowerShell hook suites (Linux), quality-checks7 3.11/3.12/3.13, and both extension test jobs.
