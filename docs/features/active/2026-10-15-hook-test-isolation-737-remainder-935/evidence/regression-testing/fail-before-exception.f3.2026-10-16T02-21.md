# Fail-Before Exception Dossier: F-3 rows (P5-T3)

Timestamp: 2026-10-16T02-21
Command: grep -r -l -F 'function Get-EpicStateIsolationHookReference' tests/scripts; grep -r -l -F 'function Get-EpicStateVariableHookLoad' tests/scripts
EXIT_CODE: 1
ExpectedExitCode: 1

State evaluated: the Phase 4 committed state `94adb8c93` (R1 and R2 delivered, no F-3 code) plus the uncommitted P5-T1 and P5-T2 rows.

WhyFailingRunImpossible: The executor cannot run CI on an intermediate commit (CI runs only on a pull request or workflow_dispatch, and the executor has no `gh`). The PoshQC MCP test tool accepts folders only and returns no per-row output, so a local call cannot isolate these rows from the rest of the folder.

SearchScope: tests/scripts
SearchPatterns: `function Get-EpicStateIsolationHookReference`, `function Get-EpicStateVariableHookLoad`
SearchResult: none (both `grep -r -l -F` searches over `tests/scripts` printed no path and exited 1). The second pattern is also a prefix of `function Get-EpicStateVariableHookLoadReport`, so that function is likewise absent.

Alternative proof (code-path reading of the Phase 4 state):
- Every `F-3 detects <Form>` row (5 rows) and every `F-3 ignores a Join-Path used only by <Reader>` row (3 rows) calls `Get-EpicStateIsolationHookReference -Ast` in its Act step. The function is absent, so each call throws `CommandNotFoundException` and each row fails.
- `F-3 process-spawning report includes a variable-built hook path` fails because the pre-change `Get-EpicStateProcessSpawningHook` returns only `Get-EpicStateHookLiteral` names, and the fixture holds no `hooks/<name>.ps1` literal (its loads are `Join-Path $HookRoot 'gate.ps1'` and `Join-Path $HookRoot $script:HookName` over a `.codex/hooks` root), so the result is empty and contains neither `gate.ps1` nor `*(.codex/hooks)`.
- The `AC-5b variable-built hook-load report <Surface>` and `F-3 non-vacuity <Surface> reports at least one variable-built hook load` rows call the absent `Get-EpicStateVariableHookLoadReport`; the AC-5b row's `Should -Not -Throw` fails and the non-vacuity row throws.
- `F-3 closure stays literal-seeded` is a guard row: the pre-change closure is already literal-seeded, so it passes before and after the change (AC-13 invariant).
