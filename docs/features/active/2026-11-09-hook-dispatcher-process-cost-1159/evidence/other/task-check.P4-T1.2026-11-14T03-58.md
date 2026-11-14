# Task check [P4-T1]

Timestamp: 2026-11-14T03-58
Command: sh SCRATCH/issue-1159-taskcheck.sh <changed files> <changed files> (Invoke-Formatter compare, Invoke-ScriptAnalyzer with pssa.settings.psd1, Invoke-Pester with Run.Path = selection, PassThru)
EXIT_CODE: 1
Output Summary: format 0 files needing change; analyzer 0 findings (one PSUseDeclaredVarsMoreThanAssignments finding in claude-settings.Tests.ps1 fixed before this run); Pester 308 passed, 6 failed, all six expected before later tasks (listed below).

## Changed files
- tests/scripts/claude-runtime/claude-settings.Tests.ps1 (partial edit from the pause commit kept; unused variable removed)
- tests/scripts/claude-runtime/docs-authoring-roles.Registration.Tests.ps1
- tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1
- tests/scripts/claude-hooks/enforce-worktree-poetry-venv.Tests.ps1 (both registration It blocks)
- tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Tests.ps1
- tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1
- tests/scripts/claude-hooks/PreToolUsePayload.Contract.Tests.ps1

## Selection and rule
The changed files are test files; the selection is the changed test files themselves (contract tests that read .claude/settings.json and the registry).

## Expected failures (acceptance is evaluated in [P7-T4])
- claude-settings: registers a single PreToolUse dispatcher entry without a timeout key -- 2 entries: enforce-owner-directive-pass-down.ps1 (arrived from origin/main, issue 1157) sits beside the dispatcher until [P7-T1].
- cleanup-merged-worktrees EndToEnd inventory row -- its exemption names enforce-owner-directive-pass-down.ps1, which is registered in the registry only after [P7-T1].
- claude-settings prd-feature byte-identical settings; docs-authoring keeps the two settings copies byte-identical -- bundle settings.json refreshed in [P6-T1].
- docs-authoring write-scope group (bundle row); preimplementation gate registration (bundle registry) -- bundle pretooluse-dispatch.json created in [P6-T1].
