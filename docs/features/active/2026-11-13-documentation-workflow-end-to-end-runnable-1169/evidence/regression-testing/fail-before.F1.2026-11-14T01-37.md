# Fail-Before Evidence F1 (Remediation Cycle 1, P1-T1)

Timestamp: 2026-11-14T01-37
Command: sh SCRATCH/issue-1169-tc.sh R1-P1-T1 (pwsh 7: Invoke-Formatter and Invoke-ScriptAnalyzer on the two edited suites, then Invoke-Pester with Run.Path = tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.DocsEstate.Tests.ps1 and tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-docs.Tests.ps1, Run.PassThru; the runner exits 1 when any test fails)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary:
- The runner does not use Run.Exit; it exits 1 on any failure, so the expected exit code of this fail-before run is 1 (the failed-row count, 9, applies only to a Run.Exit run).
- Format findings 0, lint findings 0 on both suites.
- Pester: 93 tests, 84 passed, 9 failed, 0 skipped. The nine failing rows, all on unmodified production code (single `=`-form option leaves `$rest` a scalar string in Get-OrchestrationDocsEstateSegmentShape):
  - Claude: allows a git commit with a single --file= option
  - Claude: allows a git commit with a single --message= option
  - Claude: allows a git commit with a single --trailer= option
  - Claude: allows a git -C <absolute root> commit with a single --file= option
  - Claude: command shape prefilter / returns one commit shape for a single =-form option
  - Codex: allows a git commit with a single --file= option (codex)
  - Codex: allows a git commit with a single --message= option (codex)
  - Codex: allows a git commit with a single --trailer= option (codex)
  - Codex: allows a git -C <absolute root> commit with a single --file= option (codex)
- Both two-`=`-form-option rows (`allows a git commit with two =-form options`, Claude and Codex) pass before the fix, as the plan states. Every other row passes.
