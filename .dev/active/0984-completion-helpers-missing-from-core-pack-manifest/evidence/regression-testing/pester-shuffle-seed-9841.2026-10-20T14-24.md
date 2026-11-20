# Isolation: Seeded Shuffled Pester File Order, Seed 9841 (Issue #984)

Timestamp: 2026-10-20T14-24
Command: sh SCRATCH/issue-984-run-files.sh issue-984-shuffle-9841 issue-984-eight.txt 9841 (one PowerShell 7 process; the eight touched suites ordered by System.Random(9841) keys; JUnit to artifacts/pester/pester-junit.xml; exits 1 on a non-zero JUnit failed count)
EXIT_CODE: 0
Output Summary: seed 9841; total=907 passed=907 failed=0 skipped=0; failed count 0.

Seed: 9841

File order:

- `tests/scripts/codex-hooks/codex-batch-budget.RouteImportFailure.Tests.ps1`
- `tests/scripts/claude-hooks/hook-dependency-failure.Claude.Tests.ps1`
- `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-discovery-artifact-gate.ValidationImportFailure.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-batch-budget.RouteImportFailure.Tests.ps1`
- `tests/scripts/codex-hooks/hook-dependency-failure.Codex.Tests.ps1`
- `tests/scripts/claude-runtime/hook-import-failure-exemptions.Guard.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-completion-consistency.HelperImportFailure.Tests.ps1`
