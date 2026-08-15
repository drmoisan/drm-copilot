# Guard Fixture Verification (P1-T4) — Issue #475

Timestamp: 2026-08-15T19-31

Command: `Invoke-Pester` with `Run.Path = tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` and `Filter.ExcludeTag = 'RepositoryScan'`, executed via `pwsh -NoProfile`. The two repository-scan `It`s and the enumeration `It` carry `-Tag 'RepositoryScan'` and are excluded here by design: they are legitimately red until the last Python invocation site is removed in Phase 11, and the plan runs them only at `[P1-T5]` (fail-before) and Phase 14. The plan task explicitly authorizes this filtered form ("Pester filtered to the fixture contexts, or `scan_folders` narrowed with the scan `It`s excluded by tag/filter").

EXIT_CODE: 0

Output Summary: **20 passed, 0 failed, 0 skipped, 3 not run** (the 3 not-run are the tag-excluded repository-scan `It`s). Pester v5.6.1. Duration 713 ms. The fixtures pass from the outset, as the plan requires.

## Detection Fixtures — every class reports a finding

| Class | Fixture `It` | Result |
| --- | --- | --- |
| 1 (bare) | detects a bare python invocation | PASS |
| 1 (`&`) | detects an ampersand-invoked python invocation | PASS |
| 1 (`.`) | detects a dot-invoked python invocation | PASS |
| 1 (quoted) | detects a quoted python constant invocation | PASS |
| 1 (name set) | detects python3, py, and poetry as interpreter commands | PASS (3 findings) |
| 1 (case) | detects an interpreter name written in mixed case | PASS |
| 2 (`-FilePath`) | detects a subprocess start whose FilePath is an interpreter | PASS |
| 2 (positional) | detects a subprocess start whose first positional argument is an interpreter | PASS |
| 3 (variable) | detects an ampersand-invoked variable that is not a scriptblock parameter | PASS |
| 3 (expression) | detects an ampersand-invoked expression in the command position | PASS |
| 4 (long form) | detects an Invoke-Expression call | PASS |
| 4 (alias) | detects the built-in alias of Invoke-Expression | PASS |

## Non-Detection Fixtures — every one reports zero findings

| Fixture `It` | Result |
| --- | --- |
| reports no finding for interpreter names inside string literals | PASS |
| reports no finding for interpreter names inside comments | PASS |
| reports no finding for function names beginning with Invoke-Python | PASS |
| reports no finding for a scriptblock-parameter seam invocation (carve-out a) | PASS |
| reports no finding when a seam variable differs from its parameter by letter case | PASS |
| reports no finding for dot-sourcing a sibling helper path variable (carve-out b) | PASS |
| reports no finding for a subprocess start targeting an unrelated executable | PASS |

## Allowlist State

The `ships an empty allowlist` `It` asserts `Get-PythonInvocationAllowlist` returns exactly 0 entries and passes. The allowlist is authored EMPTY and the helper header records that entries may be added only by an explicit owner decision, never by an implementer working around a failure.

## Defect Found and Fixed During This Task

The first fixture run failed 2 of 19 `It`s with `RuntimeException: You cannot call a method on a null-valued expression` at `EnforcementHooksNoPythonInvocation.Helpers.ps1`. Cause: `Get-ScriptBlockParameterName` returned a `HashSet[string]` with a bare `return`, and PowerShell enumerates a returned collection into the pipeline. An empty set therefore emitted nothing and the call site received `$null`; a populated set degraded into a plain `object[]`, whose `Contains` compares case-SENSITIVELY. Both directions broke carve-out (a).

Fix: `return , $names` (unary comma suppresses enumeration), with an explanatory comment at the return and the `.OUTPUTS` help updated. A regression fixture was added — `reports no finding when a seam variable differs from its parameter by letter case` — which pins the case-insensitive behavior that the degraded array form would have lost. Both previously failing `It`s now pass.

## Toolchain State for This Task

- `mcp__drm-copilot__run_poshqc_format` (scan_folders `tests/scripts/claude-runtime`): clean, idempotent on re-run.
- `mcp__drm-copilot__run_poshqc_analyze` (same narrowing): 0 findings. Seven findings raised during authoring were all corrected, not suppressed: 5 x `PSUseOutputTypeCorrectly`, 1 x `PSUseShouldProcessForStateChangingFunctions` (resolved by renaming `New-PythonInvocationFinding` to the non-state-changing verb form `ConvertTo-PythonInvocationFinding`), and 1 x `PSUseBOMForUnicodeEncodedFile` (resolved by removing non-ASCII characters from the file rather than adding a BOM).
- File sizes under the 500-line cap: helper 493 lines, suite 454 lines (the helper was reduced from 521 lines after the formatter expanded it, by condensing prose only — no documented requirement was dropped).
