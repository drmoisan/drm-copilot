# Fail-Before Exception Dossier: R1 and R2 rows (P4-T2)

Timestamp: 2026-10-16T01-59
Command: grep -r -l -F 'function Test-EpicStateIsolationHookReference' tests/scripts; grep -r -l -F 'function Test-EpicStateIsolationHelperDotSource' tests/scripts
EXIT_CODE: 1
ExpectedExitCode: 1

State evaluated: the Phase 3 committed state `c2dbca25a` (F-2-only predicate: F-1/F-2 reapplied, hook-reference functions moved, no R1 or R2 code) plus the uncommitted P4-T1 suite `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1`.

WhyFailingRunImpossible: The executor cannot run CI on an intermediate commit (CI runs only on a pull request or workflow_dispatch, and the executor has no `gh`). The PoshQC MCP test tool accepts folders only and returns no per-row output, so a local call cannot isolate these rows. The folder run is already red at this state because of the AC-6 Discovery rows (F-2 without R1/R2 flags the seven AC-6 suites), so a red local result would not distinguish the R1/R2 rows from those.

SearchScope: tests/scripts
SearchPatterns: `function Test-EpicStateIsolationHookReference`, `function Test-EpicStateIsolationHelperDotSource`
SearchResult: none (both `grep -r -l -F` searches over `tests/scripts` printed no path and exited 1)

Alternative proof (code-path reading of the Phase 3 state):
- R1 rows: every `R1 identifies <Case>` row (11 rows) and every `R1 does not identify <Case>` row (3 rows) calls `Test-EpicStateIsolationHookReference` in its Act step. That function is defined nowhere under `tests/scripts` (SearchResult above), so each call throws `CommandNotFoundException` and each positive row fails. The negative rows fail the same way at this state.
- R2 row (a): the F-2-only `Get-EpicStateIsolationFinding` emits `no dot-source loads the hook` for any outermost BeforeAll that has dot-sources and no identified hook (`if ($dotSources.Count -gt 0 -and $null -eq $dotSource)`). The row's fixture dot-sources only `Fixture.Helpers.ps1` and `Other.Helpers.ps1`, neither of which `Get-EpicStateIsolationHookDotSource` identifies, so the finding is emitted and, with `$dotSource` null, `Get-EpicStateIsolationPairFinding` also adds the ordering finding; the row asserts zero findings and fails.
- R2 row (b): the same F-2 statement adds `no dot-source loads the hook`, which the row asserts is absent, so the row fails.
- R2 rows (c) and (d) assert only the presence of a finding that the F-2-only predicate already emits; they are guard rows that pass before and after the change.
