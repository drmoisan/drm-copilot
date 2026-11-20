# P1-T1 CI coverage evidence for PR 924

Timestamp: 2026-10-12T19-41
Command: gh run download 38321045586 -n poshqc-test-results (orchestrator-run reading of powershell-coverage.xml under COVERAGE_READ_RULE; recorded, not re-run by the executor)
EXIT_CODE: 0
Output Summary:
- The four target hook files and the repository-wide PowerShell line total are at or above 85.00.
- All 20 PR checks on the tested head are SUCCESS.
- CI jobs poshqc / PowerShell QC and poshqc / PowerShell hook suites (Linux) are SUCCESS on the same head.

PR: 924
PR_URL: https://github.com/drmoisan/drm-copilot/pull/924
CI_RUN_ID: 38321045586
CI_WORKFLOW: CI
CI_CONCLUSION: success
CI_HEAD_SHA: c9123db7f7db50f200a639360f799d4959b4da5d
CI_PR_CHECKS: 20 of 20 SUCCESS
CI_COVERAGE_ARTIFACT: poshqc-test-results / powershell-coverage.xml
CI_JOB: poshqc / PowerShell QC SUCCESS
CI_JOB: poshqc / PowerShell hook suites (Linux) SUCCESS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=57 missed=4 line_pct=93.44 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill-helpers.ps1 covered=111 missed=3 line_pct=97.37 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.artifact-root.ps1 covered=64 missed=2 line_pct=96.97 threshold=85.00 result=PASS
COVERAGE_REPO_TOTAL: covered=16300 missed=1741 line_pct=90.35 threshold=85.00 result=PASS
AC9_LOCAL_EVIDENCE: docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p1-line-counts.2026-10-11T10-38.md
AC9_LOCAL_EVIDENCE: docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-poshqc-format.2026-10-11T10-38.md
AC9_LOCAL_EVIDENCE: docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-poshqc-analyze.2026-10-11T10-38.md
AC9_LOCAL_EVIDENCE: docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/p2-pester.2026-10-11T10-38.md
COVERAGE_STATUS: PASS
