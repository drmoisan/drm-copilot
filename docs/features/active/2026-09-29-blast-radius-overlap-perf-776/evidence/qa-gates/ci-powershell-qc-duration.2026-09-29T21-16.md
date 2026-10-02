# CI PowerShell QC Job Duration — Issue #776 (AC-3)

Timestamp: 2026-09-29T21-16
Command: gh api repos/drmoisan/drm-copilot/actions/runs/36653389492/jobs?per_page=100 (job "poshqc / PowerShell QC"; duration = completed_at - started_at)
EXIT_CODE: 0
Output Summary: PR #781 head 35a77daa8f718b90cdb5d3165851649bf1800032, CI run 1054 (id 36653389492). PowerShell QC job 478 s against 838 s in run 1043 (id 36622810274). The plan's pass condition is at most 700 s: PASS.

## Comparison

| Measure | Run 1043 (main, before) | Run 1054 (PR #781) | Change |
| --- | --- | --- | --- |
| PowerShell QC job | 838 s | 478 s | -360 s (-43%) |
| Test PowerShell step (Pester) | 698 s | 349 s | -349 s (-50%) |
| Analyze PowerShell step | 96 s | 91 s | -5 s |
| Whole CI run (created to updated) | 14m04s | 8m08s | -5m56s |

## Sources

- Run 1043: https://github.com/drmoisan/drm-copilot/actions/runs/36622810274 (push to main, 2026-09-29T19:56:51Z to 20:10:55Z)
- Run 1054: https://github.com/drmoisan/drm-copilot/actions/runs/36653389492 (pull_request, 2026-09-30T01:04:54Z to 01:13:02Z)
- All 11 required checks on PR #781 passed at head 35a77daa8f718b90cdb5d3165851649bf1800032; `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` returned `conclusion: success`.

## Note

The run durations come from single CI runs on GitHub-hosted runners, so they carry run-to-run variance. The job-level reduction (360 s) is consistent with the local timing evidence for `BlastRadius.HistoricalRuns.Tests.ps1` (median 213.12 s to 40.09 s, ratio 5.32).
