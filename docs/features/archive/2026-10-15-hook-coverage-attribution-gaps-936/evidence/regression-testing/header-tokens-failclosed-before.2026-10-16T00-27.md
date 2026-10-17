# FC header-token baseline (P0-T5) [expect-fail]

Timestamp: 2026-10-16T00-27
Command: poetry run python -I SCRATCH/cov936.py header failclosed tests/scripts/codex-hooks/hook-import-failure-exemptions.FailClosed.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: HEADER-TOKENS=INCOMPLETE, FILE-LINES=80. All ten tokens absent (expected before the change).

FILE-LINES=80
TOKEN-ABSENT #936
TOKEN-ABSENT .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1
TOKEN-ABSENT line 41
TOKEN-ABSENT H2
TOKEN-ABSENT OrchestrationFeatureFolderResolutionImportFailure
TOKEN-ABSENT Pester
TOKEN-ABSENT 5.x
TOKEN-ABSENT breakpoint
TOKEN-ABSENT compiled
TOKEN-ABSENT recompilation
HEADER-TOKENS=INCOMPLETE
