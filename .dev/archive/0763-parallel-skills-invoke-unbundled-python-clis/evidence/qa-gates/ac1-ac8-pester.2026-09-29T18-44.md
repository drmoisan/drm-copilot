# AC1 and AC8 PowerShell Gates (P6-T5)

Timestamp: 2026-09-29T18-44
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-hooks tests/scripts/claude-runtime ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Pester: `Tests Passed: 2105, Failed: 1, Skipped: 0`; process EXIT_CODE 1 from the one baseline failure.
- `JUNIT file=tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 Total=24 Passed=24 Failed=0 Other=0`
- `JUNIT file=tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 Total=7 Passed=7 Failed=0 Other=0`
- `JUNIT file=tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 Total=27 Passed=27 Failed=0 Other=0`
- No-Python suite cases with `status=Passed` (the scan now includes the three
  `.claude/lib/parallel-drift` files):
  - `enforcement hooks must not invoke Python.repository scan.reports no Python invocation beyond the allowlist across the guarded tree`
  - `enforcement hooks must not invoke Python.repository scan.enumerates only the two guarded roots and never the bundled mirror`
- `JUNIT-ALL Total=2106 Failed=1`; the single JUNIT-FAILED line is a member of the P0-T19 baseline
  failure set:
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1::enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
