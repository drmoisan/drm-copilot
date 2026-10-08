# Pass-After, New Suite Against Fixed ci.yml ([P1-T8])

Timestamp: 2026-10-08T02-30 (UTC)
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/workflows/CiWorkflow.Tests.ps1 -Output Detailed"
Route: ci-evidence
Deviation: DEV-CI-PASSAFTER, DEV-PWSH-ROUTE
ExecutedCommand: none locally; values read from workflow_dispatch CI run 37717224700, job 113116383126 "poshqc / PowerShell QC" (Invoke-PoshQCTest over the full repository at Normal verbosity)
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37717224700/job/113116383126 (workflow CI, event workflow_dispatch, head 8a1b9b8b66f4bb65ef0a5e3e1d0d883246d739f7, conclusion success)
EXIT_CODE: 0
Output Summary:
- Fix presence at the run head: `git show 8a1b9b8b:.github/workflows/ci.yml` line 7 reads `    branches: [main, development, "epic/**"]`; line 5 reads `    branches: [main, development]`. `git merge-base --is-ancestor 00798863 8a1b9b8b` exit 0 (fix commit contained). `git diff --name-only 00798863 8a1b9b8b` lists only files under docs/features/active/2026-09-08-epic-child-prs-trigger-no-ci-658/.
- `[+]` line for the suite (log line 1263, ANSI codes stripped, root redacted): `[+] <WORKSPACE_ROOT>\tests\scripts\workflows\CiWorkflow.Tests.ps1 40ms (5ms|18ms)`
- Per-It `[+]` lines: not printed. The CI run uses `Output.Verbosity = 'Normal'`, which prints one per-file `[+]` line for a file with zero failures and does not list individual passing It blocks. The two It names (`lists main, development, and epic/** in the pull_request branch filter`, `keeps the push branch filter exactly main and development`) therefore do not appear on `[+]` lines. This is the DEV-CI-PASSAFTER deviation.
- Suite result: CiWorkflow.Tests.ps1 passed with zero failures. `[-]` lines in the whole log: 0 (`grep -c '\[-\]'` on the ANSI-stripped log printed `0`).
- Full-repository counts line (log line 1268): `Tests Passed: 6521, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`. A suite-alone `Tests Passed: 2, Failed: 0` line was not produced by this route. Derived per-suite result: the [P1-T4] run (head 632fe595) recorded `Tests Passed: 6520, Failed: 1` with the pull_request It as the only failure; this run records 6521 passed and 0 failed, so both It blocks of the suite passed.
- Plan acceptance literal `Tests Passed: 2, Failed: 0` with both It names on `[+]` lines: not observed (route limitation, recorded as DEV-CI-PASSAFTER); substance (suite passes with zero failures against the fixed ci.yml) verified as above.
