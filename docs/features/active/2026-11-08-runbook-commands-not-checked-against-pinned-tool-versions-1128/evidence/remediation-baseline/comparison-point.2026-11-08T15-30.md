# Remediation comparison point (P0-T1)

Timestamp: 2026-11-08T15-30
Command: read the newest pester-baseline.*.md, pytest-baseline.*.md, and powershell-static.*.md under evidence/baseline/ (pester-baseline.2026-11-08T13-47.md, pytest-baseline.2026-11-08T13-51.md, powershell-static.2026-11-08T13-32.md); no test or source file changed
EXIT_CODE: 0
Output Summary: Pester Phase 0 baseline: tests 19584, failed 0, skipped 10, passed 19574; repo-wide line coverage 95.56% (covered 35308, missed 1639, total 36947). Pytest Phase 0 baseline: 16537 passed, 6 skipped, 0 failed; scripts.dev_tools line coverage 93.58% (16738 of 17653), branch coverage 90.17% (5787 of 6418), terminal combined 94%. PowerShell static baseline: files 708, analyzer findings 0, format drift files 0. Per-file coverage of .claude/lib/runbook/RunbookCommandVersion.psm1: absent from the Phase 0 baseline run (the file did not exist then); the pre-remediation figure from evidence/qa-gates/pester-final.2026-11-08T15-08.md is 100% (91 of 91 lines), with a final-gate suite of 19648 tests, 0 failed, 10 skipped, repo-wide 95.57% (covered 35453, missed 1643, total 37096).
