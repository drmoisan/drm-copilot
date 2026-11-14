# Phase Gate — Phase 1 (remediation cycle 1, [P1-T7])

Timestamp: 2026-11-14T05-28
Command: stage 1-2 sh SCRATCH/issue-1156-ps-static.sh (check-only Invoke-Formatter comparison and Invoke-ScriptAnalyzer with scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the 40 .ps1/.psm1/.psd1 files added or modified since the merge base of origin/main and HEAD, bundle copies included); stage 5 sh SCRATCH/issue-1156-pester-gate.sh (Import-Module scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCParallelTest -Root <item worktree root>; exits with the returned ExitCode) and sh SCRATCH/issue-1156-pytest-final.sh (VIRTUAL_ENV unset: poetry run pytest -n auto --cov --cov-branch --cov-report=term-missing:skip-covered --cov-report=json:artifacts/python/coverage-final.json --junitxml=artifacts/python/junit-final.xml -q -p no:cacheprovider)
EXIT_CODE: 0
Output Summary:
- Single clean pass; no stage failed or rewrote a file (git status --porcelain empty before and after).
- Format: 40 files, 0 with drift. Analyze: 0 findings. Type check: not applicable (PowerShell; no Python or TypeScript source changed).
- Architecture-boundary tests: not applicable (no dependency-cruiser or NetArchTest surface touched).
- Pester: one Invoke-PoshQCParallelTest run, 8 shards all exit 0, ExitCode 0, 1276.57 s. artifacts/pester/pester-junit.xml: 24344 tests, 0 failures, 0 errors, 10 skipped, 24334 passed. Named suites: `Invoke-RegenerationPath.ProcessStart.Tests.ps1` 17/0, `enforcement-hooks-no-python-invocation.Tests.ps1` 35/0, `Invoke-RegenerationPath.Tests.ps1` 123/0 (74 result-table rows, 0 failed), `FileSizePolicy.RepoGate.Tests.ps1` 5/0.
- PowerShell line coverage (artifacts/pester/powershell-coverage.xml): repo-wide 95.90% (40303 covered, 1722 missed); `.claude/lib/regeneration/Invoke-RegenerationPath.ps1` 91.28% (293 covered, 28 missed).
- pytest: one `pytest -n auto` run, 16729 passed, 6 skipped, 0 failed (270.89 s); JUnit 16735 cases, 0 failures, 0 errors. Line 97.13% (34574/35595), branch 94.42% (12785/13540), from the JSON report totals. The push-down and mirror contract tests run inside this suite.
- Contract checks (stage 6): the bundle copy of the adapter equals its source (SHA-256 recorded in `evidence/other/task-check.P1-T2.2026-11-14T04-55.md`); the push-down contract tests pass within the pytest run.
- Expected failures: none.
