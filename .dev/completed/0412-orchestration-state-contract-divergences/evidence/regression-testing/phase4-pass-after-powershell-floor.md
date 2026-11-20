# Phase 4 pass-after — Get-ComplexityFloor floor-signal filtering ([P4-T11])

Timestamp: 2026-07-25T18-41

Command: `pwsh -NoProfile -Command "Import-Module ./.claude/lib/model-routing/ModelRouting.psm1; Get-ComplexityFloor -SignalsPresent @('docs_or_comment_only'); Get-ComplexityFloor -SignalsPresent @('cross_module_contract_change')"` (run from the repository root)

EXIT_CODE: 0

Output Summary:

Exact verbatim output of the planned command:

```
C1
C3
```

This matches the expected post-fix result: `C1` then `C3`. The [P0-T15] fail-before artifact
recorded `C3` for `@('docs_or_comment_only')`, a `"floor": false` signal; that defect is now
resolved.

Supplementary five-input cross-language reference check (same module import, same session),
confirming byte-for-byte agreement with the Python `compute_complexity_floor` behavior
verified in [P2-T9]:

Command: `pwsh -NoProfile -Command "Import-Module ./.claude/lib/model-routing/ModelRouting.psm1; Get-ComplexityFloor -SignalsPresent @(); Get-ComplexityFloor -SignalsPresent @('docs_or_comment_only'); Get-ComplexityFloor -SignalsPresent @('not_a_real_signal'); Get-ComplexityFloor -SignalsPresent @('cross_module_contract_change'); Get-ComplexityFloor -SignalsPresent @('docs_or_comment_only','auth_or_token_handling')"`

Verbatim output:

```
C1
C1
C1
C3
C3
```

| Input | PowerShell `Get-ComplexityFloor` | Python `compute_complexity_floor` | Match |
|---|---|---|---|
| `[]` | `C1` | `C1` | yes |
| `['docs_or_comment_only']` | `C1` | `C1` | yes |
| `['not_a_real_signal']` | `C1` | `C1` | yes |
| `['cross_module_contract_change']` | `C3` | `C3` | yes |
| `['docs_or_comment_only','auth_or_token_handling']` | `C3` | `C3` | yes |

`C4` is never returned in any case.
