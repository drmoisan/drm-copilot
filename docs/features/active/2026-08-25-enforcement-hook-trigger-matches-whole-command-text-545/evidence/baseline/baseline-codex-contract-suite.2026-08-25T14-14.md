# Phase 0 — Baseline Codex contract suite (issue #545)

Timestamp: 2026-08-25T14-14

Task: [P0-T10]

Command:

```powershell
Import-Module Pester -MinimumVersion 5.0 -Force
$c = New-PesterConfiguration
$c.Run.Path = "tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1"
$c.Run.PassThru = $true
$r = Invoke-Pester -Configuration $c
```

EXIT_CODE: 0

## The three named results

| Gate | `It` name as reported | Result |
| --- | --- | --- |
| Byte-identity (Codex pair) | `keeps the canonical hooks byte-identical to their bundled copies` | **PASS** |
| Pack manifest | `lists every shared hook module in the core pack manifest` | **PASS** |
| 500-line cap (with parse check) | `parse-checks each root and bundled hook and keeps every file within 500 lines` | **PASS** |

Three further contract gates in the same suite, which [P11-T6] also reports, likewise passed at
baseline: `reads stdin in every hook entrypoint`, and
`contains no legacy Claude environment-variable dependency in hooks or shared modules`.

## Output Summary

- TotalCount: **43**
- Passed: **43**
- Failed: **0**
- Skipped: **0**
- Result: `Passed`

The suite is green at baseline. All three gates this plan must keep green — the Codex
canonical/bundle byte-identity assertion, the core pack-manifest membership assertion, and the
combined parse-check and 500-line cap — pass before any change is made. This is the comparison
point for [P11-T6], and it is also the suite whose `$script:SharedModuleNames` array [P5-T5] edits
on its single line without changing the file's total line count of 494.
