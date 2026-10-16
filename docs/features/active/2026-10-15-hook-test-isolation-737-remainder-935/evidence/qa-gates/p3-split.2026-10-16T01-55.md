# Phase 3 Split of EpicStateIsolation.Helpers.ps1 (P3-T1..P3-T3)

Timestamp: 2026-10-16T01-55
Command: sh SCRATCH/935/issue-935/p3-split.sh (copies the Phase 2 helper lines 96-179 verbatim under a new header, removes lines 96-180 from the helper, inserts the dot-source after the header `#>`, then runs `awk 'END { print NR }'`, `grep -c -E` and per-name `grep -c -F -e 'function <name>'` on both files)
EXIT_CODE: 0

Output Summary: each moved name has count 1 in the HookReference helper and 0 in `EpicStateIsolation.Helpers.ps1`; both line counts are at or below 500. PASS.

| File | Lines |
| --- | --- |
| tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 | 98 |
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 412 (at or below 420) |

| Function | HookReference helper | EpicStateIsolation.Helpers.ps1 |
| --- | --- | --- |
| Test-EpicStateIsolationHookLiteral | 1 | 0 |
| Get-EpicStateIsolationVariableKey | 1 | 0 |
| Test-EpicStateIsolationVariableBoundToHook | 1 | 0 |
| Get-EpicStateIsolationHookDotSource | 1 | 0 |

- P3-T1 pattern `^function (Test-EpicStateIsolationHookLiteral|Get-EpicStateIsolationVariableKey|Test-EpicStateIsolationVariableBoundToHook|Get-EpicStateIsolationHookDotSource) `: 4 on the HookReference helper, 0 on `EpicStateIsolation.Helpers.ps1`.
- `grep -c -F -e 'EpicStateIsolation.HookReference.Helpers.ps1'` on `EpicStateIsolation.Helpers.ps1`: 1.
- `Test-EpicStateIsolationConditionalAncestor` remains in `EpicStateIsolation.Helpers.ps1`.
