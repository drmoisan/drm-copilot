# Baseline Sibling Pester Contract Suites ([P0-T22])

Timestamp: 2026-10-07T21-58
Command: pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-runtime/claude-runtime-structure.Tests.ps1,tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1,tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1 -Output Normal"
Route: ci-evidence
Deviation: DEV-CI-BASELINE, DEV-PWSH-ROUTE
ExecutedCommand: none locally; values read from CI run 37645267440, job 112874273719 "poshqc / PowerShell QC"
CiRun: https://github.com/drmoisan/drm-copilot/actions/runs/37645267440/job/112874273719 (workflow CI, event push, head 08ee030d9584bf15882fbb3654c8e38f34c7c359, conclusion success)
EXIT_CODE: 0
ExpectedExitCode: 0
Output Summary:
- Scope: the three sibling suites live under tests/scripts, which is in the CI test scan set (config/poshqc-scan.json), so they ran inside the full-repository Pester run.
- Counts line (log line 1274, full-repository scope, ANSI codes stripped): `Tests Passed: 6519, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`
- Per-suite lines (ANSI codes stripped, root redacted):
  - log line 1020: `[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\checkpoint-hygiene-skill-contract.Tests.ps1`
  - log line 1022: `[+] <WORKSPACE_ROOT>\tests\scripts\claude-runtime\claude-runtime-structure.Tests.ps1`
  - log line 1033: `[+] <WORKSPACE_ROOT>\tests\scripts\codex-hooks\codex-epic-runtime-contracts.Tests.ps1`
- Failed: 0
- BaselineFailingTests: none
- Item branch differs from 08ee030d only in documentation files.
