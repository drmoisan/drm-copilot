# Bash Final Gate from CI on the Branch, Correction (remediation P2-T8)

Timestamp: 2026-11-10T03-17
Command: git commit -F SCRATCH/issue-1164-commit-correction.txt; git push; gh workflow run ci.yml --ref feature/parallel-planner-time-based-edge-rule-1164; gh run view 42746009388 --json status,conclusion,headSha,jobs; gh api --allow-escape-sequences repos/drmoisan/drm-copilot/actions/jobs/129598288522/logs; gh run download 42746009388 -n shell-coverage -D SCRATCH/shell-corr
EXIT_CODE: 0
Output Summary:
- Commit 02f7ff8694b3984508cefe06b44eafa427dada76 pushed with a plain git push (e74be9896..02f7ff869); git rev-parse HEAD equals @{u}.
- Run: 42746009388 (ci.yml, event workflow_dispatch, head ref feature/parallel-planner-time-based-edge-rule-1164, head 02f7ff8694b3984508cefe06b44eafa427dada76, equal to the pushed HEAD); one dispatch for this head; run conclusion success. URL: https://github.com/drmoisan/drm-copilot/actions/runs/42746009388
- shell-coverage / Shell Coverage (Bats + kcov) (job 129598288522): success.
- Run shell-qc check (shfmt diff + shellcheck) step: success, finding count 0 (the step fails on any finding). This is the bash final static record.
- Run shell-qc test with coverage step: success. Bats: plan 1..799; 799 ok, 0 not ok (P0-T1 baseline: 799 ok, 0 not ok).
- tests/shell/parallel_manifest_parity.bats: ok 154 "the manifest parity corpus meets the declared floor", ok 155 "python3 is available to read the corpus", ok 156 "the bash lane reproduces every manifest corpus fixture".
- kcov repo-wide line coverage (cov.xml): 3457 / 3644 = 94.9% (P0-T1 baseline 94.9%).
- kcov line coverage of .claude/lib/bash/parallel-manifest-pairs.sh: 68 / 68 = 100.00% (P0-T1 baseline 68 / 68 = 100.00%); no drop. The added comment lines are not instrumented.
- CI Required Gate (job 129605885997): success. All 23 jobs of the run concluded success, including poshqc / PowerShell QC, the three PowerShell QC shards, PowerShell QC static, PowerShell hook suites (Linux), quality-checks7 3.11/3.12/3.13, both extension test jobs, and both root TypeScript test jobs.
