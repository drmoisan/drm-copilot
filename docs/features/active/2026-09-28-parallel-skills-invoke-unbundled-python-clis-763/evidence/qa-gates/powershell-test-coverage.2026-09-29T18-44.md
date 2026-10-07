# PowerShell Test With Coverage and Regression (P8-T5)

Timestamp: 2026-09-29T18-44
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-selfhosted.ps1 tests/scripts/claude-lib tests/scripts/claude-hooks tests/scripts/claude-runtime ; poetry run python SCRATCH/junit-cases.py artifacts/pester/pester-junit.xml <nine suffixes> ; poetry run python SCRATCH/jacoco-files.py artifacts/pester/powershell-coverage.xml .claude/lib/parallel-drift/ParallelDriftHalt.psm1 .claude/lib/parallel-drift/ParallelDrift.psm1 .claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 .claude/hooks/enforce-parallel-abandon-gate.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- Pester: `Tests Passed: 3914, Failed: 1, Skipped: 1`; `Covered 70.31% / 0%. 15,578 analyzed Commands in 120 Files.`;
  process EXIT_CODE 1 from the single baseline failure.
- Nine `JUNIT file=` lines, each `Failed=0`, no `MISSING` line:
  - `JUNIT file=parallel-drift/ParallelDriftHalt.Tests.ps1 Total=28 Passed=28 Failed=0 Other=0`
  - `JUNIT file=parallel-drift/ParallelDrift.Tests.ps1 Total=26 Passed=26 Failed=0 Other=0`
  - `JUNIT file=parallel-drift/ParallelDrift.Manifest.Tests.ps1 Total=5 Passed=5 Failed=0 Other=0`
  - `JUNIT file=parallel-drift/Invoke-ParallelDriftDetection.Tests.ps1 Total=21 Passed=21 Failed=0 Other=0`
  - `JUNIT file=parallel-drift/ParallelDrift.Parity.Tests.ps1 Total=20 Passed=20 Failed=0 Other=0`
  - `JUNIT file=tests/scripts/claude-hooks/enforce-parallel-abandon-gate.Tests.ps1 Total=24 Passed=24 Failed=0 Other=0`
  - `JUNIT file=tests/scripts/claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1 Total=7 Passed=7 Failed=0 Other=0`
  - `JUNIT file=tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1 Total=27 Passed=27 Failed=0 Other=0`
  - `JUNIT file=tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1 Total=6 Passed=6 Failed=0 Other=0`
- `JUNIT-ALL Total=3916 Failed=1`; the only JUNIT-FAILED line is a member of the P0-T19 baseline
  failure set:
  `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1::enforce-pr-author-skill.ps1.allowed commands.allows gh pr create --body-file artifacts/pr_body_12.md when context exists`
- Coverage (JaCoCo LINE counters):
  - `JACOCO file=.claude/lib/parallel-drift/ParallelDriftHalt.psm1 Covered=67 Missed=0 LinePercent=100.00` (>= 85)
  - `JACOCO file=.claude/lib/parallel-drift/ParallelDrift.psm1 Covered=123 Missed=0 LinePercent=100.00` (>= 85)
  - `JACOCO file=.claude/lib/parallel-drift/Invoke-ParallelDriftDetection.ps1 Covered=91 Missed=5 LinePercent=94.79` (>= 85)
  - `JACOCO file=.claude/hooks/enforce-parallel-abandon-gate.ps1 Covered=73 Missed=5 LinePercent=93.59`
    (P0-T19 baseline 93.59; not below baseline)
- Pester reports no branch coverage; no PowerShell branch threshold applies.

## Rerun after the Python-loop SKILL fix (toolchain loop rule)

The Python loop's fix `0e41ad84` changed `.claude/skills/parallel-orchestrate/SKILL.md`, which two
PowerShell suites read (`tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`
and `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1`), so this task was rerun with
the same command on commit `0e41ad84`:
- `Tests Passed: 3914, Failed: 1, Skipped: 1`; `Covered 70.31% / 0%. 15,578 analyzed Commands in 120 Files.`; EXIT_CODE 1.
- The nine named JUNIT lines above are unchanged, each `Failed=0`; additionally
  `JUNIT file=tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1 Total=11 Passed=11 Failed=0 Other=0`
  and `JUNIT file=tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1 Total=48 Passed=48 Failed=0 Other=0`.
- `JUNIT-ALL Total=3916 Failed=1`; the single JUNIT-FAILED line is the same P0-T19 baseline failure.
- JaCoCo unchanged: ParallelDriftHalt.psm1 100.00, ParallelDrift.psm1 100.00,
  Invoke-ParallelDriftDetection.ps1 94.79, enforce-parallel-abandon-gate.ps1 93.59.
