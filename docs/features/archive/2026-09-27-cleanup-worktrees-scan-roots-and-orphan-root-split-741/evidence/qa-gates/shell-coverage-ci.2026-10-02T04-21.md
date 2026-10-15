# P2-T12 Final CI run with kcov coverage on FINAL_SHA (CI-sourced; DEV-2, DEV-3)

Timestamp: 2026-10-02T04-21
Command: `gh workflow run _shell-coverage.yml --ref bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741` (dispatched by the orchestrator at DISPATCH_START 2026-10-02T08:12:18Z UTC); `gh run view 36982722154 --json status,conclusion,headSha`; `gh run view 36982722154 --log | grep -F "coverage (lines)"`; `gh run view 36982722154 --log | grep -c "not ok"`; `gh run download 36982722154 -n shell-coverage -D SCRATCH/ci-final-sha` (all run by the orchestrator, DEV-3); per-file line rates read by the executor with Grep over the `<class>` elements of SCRATCH/ci-final-sha/cov.xml; A1 `changed-line-coverage.sh` not run (DEV-2), changed-line values derived in P2-T13.
EXIT_CODE: 0
Output Summary:
- FINAL_RUN_ID 36982722154: https://github.com/drmoisan/drm-copilot/actions/runs/36982722154 ; job "Shell Coverage (Bats + kcov)" https://github.com/drmoisan/drm-copilot/actions/runs/36982722154/job/110760676892.
- status completed ; conclusion success ; headSha 10c6ac2951786a80327d0fff4041d6d8bb06885b (equals FINAL_SHA).
- Steps "Run shell-qc check (shfmt diff + shellcheck)" and "Run shell-qc test with coverage" both succeeded.
- TAP plan line `1..521` (= 507 baseline + 16 added - 2 moved); `not ok` lines: 0 (pass condition).
- Log line: `Bash coverage (lines): 93.8%` -> FINAL_AGGREGATE = 93.8.
- LINE-RATE (cov.xml `<class>` line-rate, verified by the executor; each >= 0.850):
  - .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_enumerate_lib.sh 0.953 (cov.xml line 984)
  - .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh 0.879 (cov.xml line 454)
  - .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh 0.906 (cov.xml line 2171)
  - .claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_scan_helper.sh 0.873 (cov.xml line 10)
  - .claude/skills/cleanup-merged-worktrees/scripts/cleanup-worktrees.sh 0.976 (cov.xml line 1586)
- CHANGED-line values (instrumented, covered, missed): recorded in FEATURE/evidence/qa-gates/coverage-delta.2026-10-02T04-22.md (P2-T13), derived from `git diff -U0 BASE_SHA` and the same cov.xml without A1 (DEV-2).
- Deviation: DEV-2 (A1 not run; no local shell route) and DEV-3 (orchestrator holds gh). Coverage artifact path recorded as SCRATCH/ci-final-sha/cov.xml.
- Result: PASS.
