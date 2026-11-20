# Preflight Fixes

Timestamp: 2026-10-31T05-21
Plan: docs/features/active/2026-10-30-docs-surface-analyzer-python-native-1031/plan.2026-10-30T18-38.md

Each entry is a trivial defect fixed in task text only. No task was added, removed or reordered.

1. [P0-T4] | changed-existing-behavior disposition (validator-blind) | Added `tests/scripts/codex-hooks` to the search scope, because `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` dot-sources the guard helpers and asserts zero `Get-PythonInvocationFinding` findings for `.codex/hooks` files; recorded it as unchanged (no `.codex/hooks` seam call has a constant interpreter target).
2. [P0-T4] | changed-existing-behavior disposition (validator-blind) | Named the guard cases `It 'reports no finding for a scriptblock-parameter seam invocation'` and `It 'reports no finding when a seam variable differs from its parameter by letter case'` as unchanged (detection class 5 does not fire on their targets).
3. [P0-T4] | changed-existing-behavior disposition (validator-blind) | Named `it("excludes Python files at every depth")` of `extensions/drm-copilot/test/packaging/mcp-server-prepack.test.ts`, which asserts the `shouldCopy` behavior that [P5-T3] changes, as unchanged (its paths lie outside the carve-out).
4. [P0-T4] and [P4-T5] | changed-existing-behavior disposition (validator-blind) | The 1020 registry suite also asserts that the committed registry has zero rows; the planned update now covers the native-table emptiness case and any committed-registry row-count case in the same file.
5. [P0-T4] | changed-existing-behavior disposition (validator-blind) | Named the 1022 `DocsInventory.Tests.ps1` case that scans module texts for a `Context` reference: unchanged when it names the 1022 modules, updated in [P4-T6] to exclude `DocsAnalyzerPythonNative.psm1` when it enumerates `LIB`.
6. [P4-T7] | gate completion for a named unchanged test | Added the unchanged codex-hooks suite to the Pester gate so its unchanged disposition is verified.
7. [P5-T3] | gate completion for a named unchanged test | Added `test/packaging/mcp-server-prepack.test.ts` (unchanged) to the Jest gate so the `shouldCopy` disposition is verified.
8. [P6-T7] | task-ordering unsatisfiable condition (validator-blind) | The acceptance requires `git status --porcelain` identical before and after while tolerating up to the [P0-T7] count of `Formatted:` lines; a writing formatter run would rewrite those files. The task now uses the same non-writing `WriteFile` seam as [P0-T7]; the assertions are unchanged.
9. `## Execution Context` Pester gate bullet | stale statement | The statement that no suite of this plan runs on `ubuntu-latest` became inaccurate after fix 6; it now states that no suite the plan creates or edits runs there and that the unchanged codex-hooks suite also runs in `poshqc / PowerShell hook suites (Linux)` without coverage.
