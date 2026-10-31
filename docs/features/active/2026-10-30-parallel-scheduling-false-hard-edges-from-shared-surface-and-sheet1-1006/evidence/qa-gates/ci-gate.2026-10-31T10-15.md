# S9 CI Gate (issue #1006, PR #1043)

Timestamp: 2026-10-31T10-15
Command: gh pr checks 1043; gh run view 41182490406 --json jobs
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Head 5981ad1779e63975959a330396c0bd95a39ed25e, CI run 41190177428 (full run; "CI full run" passed).
- All eleven required contexts of ruleset 15241672 passed: drm-copilot-extension-tests (ubuntu-latest, windows-latest), docs-validation, poshqc / PowerShell QC, shell-coverage, security-scan, quality-checks7 (3.10, 3.11, 3.12, 3.13), build-check.
- Non-required failures: "NPM Audit Gate / npm audit (.)" and "NPM Audit Gate / npm audit (extensions/drm-copilot)". Both also fail on main at the merge base 1898400756e909b88cde5f51a05f0b11d423d3b0 (run 41182490406, event push). This is the main-wide condition tracked by issue #1041; no npm manifest or lockfile was changed for it.
- Exit code 1 is the gh pr checks result caused by those two non-required failures.
