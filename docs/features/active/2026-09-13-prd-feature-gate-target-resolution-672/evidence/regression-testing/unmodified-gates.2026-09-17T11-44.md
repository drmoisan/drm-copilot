# Six Unmodified PowerShell Gates — Baseline Versus Post-Change

Timestamp: 2026-09-17T11-44

Command: `$junit = [xml](Get-Content -Raw -LiteralPath 'artifacts/pester/pester-junit.xml')`, then for each suite file name, `@($junit.SelectNodes('//testcase') | Where-Object { $_.classname.EndsWith('<file>') })`, counting matched nodes carrying a child `failure` element as failures. The report is the one produced by `[P4-T21]`'s direct `Invoke-PoshQCTest` run; the suites were not re-run. Executed from the worktree root through the scratchpad wrapper `sh runps.sh suites.ps1`. Baseline figures are carried from `evidence/baseline/baseline-unmodified-gates.2026-09-17T10-36.md`.

EXIT_CODE: 0

Output Summary:

| suite | baseline passed | post-change passed | post-change failed |
| --- | --- | --- | --- |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` | 15 | 15 | 0 |
| `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1` | 6 | 6 | 0 |
| `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` | 27 | 27 | 0 |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-absolute-paths.Tests.ps1` | 33 | 33 | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1` | 56 | 56 | 0 |
| `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 12 | 12 | 0 |

Every suite's post-change pass count is greater than or equal to its baseline, and every post-change fail count is 0. None of the six files was edited: none appears in the change-set enumeration recorded in `change-set-boundary.2026-09-17T11-45.md`. The last two are required here by `spec.md` line 637.

The `enforcement-hooks-no-python-invocation` suite passing is additionally the confirmation that this change introduced no Python into the enforcement path: the hook and its sibling remain PowerShell only.
