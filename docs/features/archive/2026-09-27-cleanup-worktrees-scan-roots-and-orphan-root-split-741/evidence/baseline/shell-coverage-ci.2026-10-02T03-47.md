# P0-T12 Baseline CI coverage readout for BASELINE_RUN_ID 36978610292 (CI-sourced; DEV-2, DEV-3)

Timestamp: 2026-10-02T03-47
Command: `gh run view 36978610292 --json status,conclusion,headSha`; `gh run view 36978610292 --log | grep -F "coverage (lines)"`; `gh run view 36978610292 --log | grep -c "not ok"`; `gh run download 36978610292 -n shell-coverage` (all run by the orchestrator, DEV-3); A1 `changed-line-coverage.sh` not run (DEV-2); per-file line rates read by the orchestrator from the `<class>` elements of the downloaded cov.xml.
EXIT_CODE: 0
Output Summary:
- Run https://github.com/drmoisan/drm-copilot/actions/runs/36978610292 ; job "Shell Coverage (Bats + kcov)" https://github.com/drmoisan/drm-copilot/actions/runs/36978610292/job/110747827997.
- status completed ; conclusion success ; headSha df5eb303129a30289a7d81775fdadaa40631be63 (equals BASE_SHA) ; completed 2026-10-02T07:33:06Z.
- Log line: `Bash coverage (lines): 93.7%` -> BASELINE_AGGREGATE = 93.7.
- `not ok` count: 0 (pass condition).
- Per-file cov.xml line-rate (CHANGED-SH): cleanup_worktrees_enumerate_lib.sh 0.924 ; cleanup_worktrees_report_records_lib.sh 0.890 ; cleanup_worktrees_preserve_lib.sh 0.906 ; cleanup_worktrees_scan_helper.sh 0.875 ; cleanup-worktrees.sh 0.976.
- Changed-line coverage at baseline: n/a (A1 not run under DEV-2; at BASE_SHA there are no changed lines relative to BASE_SHA).
- Deviation: DEV-2 (no A1 / no local shell route) and DEV-3 (orchestrator holds gh). Values supplied by the orchestrator in the segment 2 directive.
