# PowerShell Test and Coverage Baseline (P0-T19)

Timestamp: 2026-09-29T17-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-lib tests/scripts/claude-hooks tests/scripts/claude-runtime ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 ; poetry run python SCRATCH/jacoco-files.py artifacts/pester/powershell-coverage.xml .claude/hooks/enforce-parallel-abandon-gate.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Pester: `Tests Passed: 3814, Failed: 1, Skipped: 1` in 502.67s; `Covered 69.57% / 0%. 15,171 analyzed Commands in 117 Files.`; process EXIT_CODE 1 (caused by the one pre-existing failure below)
- `JUNIT-ALL Total=3816 Failed=1`
- PowerShell baseline failure set (JUNIT-FAILED lines):
  - `JUNIT-FAILED tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1::enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Per-suffix lines:
  - `JUNIT file=tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 Total=24 Passed=24 Failed=0 Other=0`
  - `JUNIT file=tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 Total=7 Passed=7 Failed=0 Other=0`
  - `JUNIT file=tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 Total=27 Passed=27 Failed=0 Other=0`
  - No `MISSING` line.
- JaCoCo: `JACOCO file=.claude/hooks/enforce-parallel-abandon-gate.ps1 Covered=73 Missed=5 LinePercent=93.59`
- The three new PowerShell production files (`.claude/lib/parallel-drift/ParallelDriftHalt.psm1`,
  `.claude/lib/parallel-drift/ParallelDrift.psm1`,
  `.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1`) have no baseline: they are absent
  at BASE_SHA.

The one failing test is outside this plan's scope (it exercises the PR-author hook, which this plan
does not touch) and is recorded as the pre-existing baseline failure set.
