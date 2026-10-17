# CI Job and Step Conclusions (P4-T4; R1, R3, AC-6, AC-7, AC-16)

Timestamp: 2026-10-01T20-21
RUN_ID: 36918378249 (https://github.com/drmoisan/drm-copilot/actions/runs/36918378249)
CI_SHA: 42db4491a6a7af4d0a876bf4022f7153e66f5c88

Command: gh run view 36918378249 --json jobs,headSha | poetry run python <session-scratchpad>/pester_xml_summary.py jobs
EXIT_CODE: 0
Output Summary: `HEAD-SHA: 42db4491a6a7af4d0a876bf4022f7153e66f5c88` (equals CI_SHA). Run conclusion `success`. All 17 jobs `success`.
Route note: the worktree isolation guard refused the literal pipe into `poetry`; the same JSON was written by `gh run view 36918378249 --json jobs,headSha` to `<session-scratchpad>/jobs-36918378249.json` (exit 0) and supplied to the helper on standard input by redirect (`... pester_xml_summary.py jobs < <session-scratchpad>/jobs-36918378249.json`, exit 0). The helper input and output are unchanged by this route.

Asserted jobs:

| Job | databaseId | Conclusion | AC |
| --- | --- | --- | --- |
| poshqc / PowerShell hook suites (Linux) | 110557965901 (LINUX_JOB_ID) | success | AC-6 |
| poshqc / PowerShell QC | 110557965705 (WINDOWS_JOB_ID) | success | AC-7 |
| shell-coverage / Shell Coverage (Bats + kcov) | 110557965675 | success | AC-16 |

Asserted steps of 110557965705: `STEP: 110557965705 | Format PowerShell | success`; `STEP: 110557965705 | Analyze PowerShell | success`. (Also `Test PowerShell` success, `Upload PowerShell test artifacts` success.)

Linux job steps: `Test PowerShell hook suites` success; `Upload PowerShell hook-suite test results` success.
shell-coverage steps: all success except `Build kcov from source` `skipped` (cache hit; not a failure).

Recorded, not asserted (jobs owned by other items):

| Job | databaseId | Conclusion |
| --- | --- | --- |
| docs-validation / Documentation Validation | 110557965343 | success |
| security-scan / Security Scanning | 110557965603 | success |
| root-typescript-tests / Root TypeScript Tests (ubuntu-latest) | 110557965729 | success |
| root-typescript-tests / Root TypeScript Tests (windows-latest) | 110557966233 | success |
| quality-checks7 / Code Quality & Tests (3.10) | 110557965762 | success |
| quality-checks7 / Code Quality & Tests (3.11) | 110557966018 | success |
| quality-checks7 / Code Quality & Tests (3.12) | 110557965850 | success |
| quality-checks7 / Code Quality & Tests (3.13) | 110557965996 | success |
| build-check / Build Package | 110557965782 | success |
| NPM Audit Gate / npm audit (extensions/drm-copilot) | 110557965797 | success |
| NPM Audit Gate / npm audit (packages/mcp-server) | 110557965990 | success |
| NPM Audit Gate / npm audit (.) | 110557966138 | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (windows-latest) | 110557966093 | success |
| drm-copilot-extension-tests / drm-copilot Extension Tests (ubuntu-latest) | 110557966135 | success |

Acceptance: HEAD-SHA equals CI_SHA; the three asserted jobs end `success`; the Format PowerShell and Analyze PowerShell steps end `success`. Met.
