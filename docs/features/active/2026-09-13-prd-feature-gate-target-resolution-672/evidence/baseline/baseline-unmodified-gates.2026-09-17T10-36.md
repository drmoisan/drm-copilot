# Baseline State of the Six Must-Not-Regress PowerShell Suites

Timestamp: 2026-09-17T10-36

Command: `$junit = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml')`, then for each suite file name, `@($junit.SelectNodes('//testcase') | Where-Object { $_.classname.EndsWith('<file>') })` with failures counted as matched nodes carrying a child `failure` element. The report was produced by the `[P0-T5]` direct `Invoke-PoshQCTest` run; the suites were not re-run. Executed from the worktree root through the scratchpad wrapper `sh runps.sh suites.ps1`.

EXIT_CODE: 0

Output Summary (pass count / fail count per suite):
- `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`: 15 passed / 0 failed
- `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`: 6 passed / 0 failed
- `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`: 27 passed / 0 failed
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1`: 33 passed / 0 failed
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`: 56 passed / 0 failed
- `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1`: 12 passed / 0 failed

The last two are required by `spec.md` line 637. None of the two pre-existing baseline failures recorded in `baseline-poshqc-test.2026-09-17T10-34.md` lies in any of these six suites.
